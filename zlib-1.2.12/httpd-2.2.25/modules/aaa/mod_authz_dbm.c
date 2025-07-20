/* Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#define APR_WANT_STRFUNC
#include "apr_want.h"
#include "apr_strings.h"
#include "apr_dbm.h"
#include "apr_md5.h"

#include "httpd.h"
#include "http_config.h"
#include "http_core.h"
#include "http_log.h"
#include "http_protocol.h"
#include "http_request.h"   /* for ap_hook_(check_user_id | auth_checker)*/

#include "mod_auth.h"

typedef struct {
    char *grpfile;
    char *dbmtype;
    int authoritative;
} authz_dbm_config_rec;

/* This should go into APR; perhaps with some nice
 * caching/locking/flocking of the open dbm file.
 */
static char *get_dbm_entry_as_str(apr_pool_t *pool, apr_dbm_t *f, char *key)
{
    apr_datum_t d, q;
    q.dptr = key;

#ifndef NETSCAPE_DBM_COMPAT
    q.dsize = strlen(q.dptr);
#else
    q.dsize = strlen(q.dptr) + 1;
#endif

    if (apr_dbm_fetch(f, q, &d) == APR_SUCCESS && d.dptr) {
        return apr_pstrmemdup(pool, d.dptr, d.dsize);
    }

    return NULL;
}

static void *create_authz_dbm_dir_config(apr_pool_t *p, char *d)
{
    authz_dbm_config_rec *conf = apr_palloc(p, sizeof(*conf));

    conf->grpfile = NULL;
    conf->dbmtype = "default";
    conf->authoritative = 1;  /* fortress is secure by default */

    return conf;
}

static const command_rec authz_dbm_cmds[] =
{
    AP_INIT_TAKE1("AuthDBMGroupFile", ap_set_file_slot,
     (void *)APR_OFFSETOF(authz_dbm_config_rec, grpfile),
     OR_AUTHCFG, "database file containing group names and member user IDs"),
    AP_INIT_TAKE1("AuthzDBMType", ap_set_string_slot,
     (void *)APR_OFFSETOF(authz_dbm_config_rec, dbmtype),
     OR_AUTHCFG, "what type of DBM file the group file is"),
    AP_INIT_FLAG("AuthzDBMAuthoritative", ap_set_flag_slot,
     (void *)APR_OFFSETOF(authz_dbm_config_rec, authoritative),
     OR_AUTHCFG, "Set to 'Off' to allow access control to be passed along to "
     "lower modules, if the group required is not found or empty, or the user "
     " is not in the required groups. (default is On.)"),
    {NULL}
};

module AP_MODULE_DECLARE_DATA authz_dbm_module;

/* We do something strange with the group file.  If the group file
 * contains any : we assume the format is
 *      key=username value=":"groupname [":"anything here is ignored]
 * otherwise we now (0.8.14+) assume that the format is
 *      key=username value=groupname
 * The first allows the password and group files to be the same
 * physical DBM file;   key=username value=password":"groupname[":"anything]
 *
 * mark@telescope.org, 22Sep95
 */

static apr_status_t get_dbm_grp(request_rec *r, char *key1, char *key2,
                                char *dbmgrpfile, char *dbtype,
                                const char ** out)
{
    char *grp_colon, *val;
    apr_status_t retval;
    apr_dbm_t *f;

    retval = apr_dbm_open_ex(&f, dbtype, dbmgrpfile, APR_DBM_READONLY,
                             APR_OS_DEFAULT, r->pool);

    if (retval != APR_SUCCESS) {
        return retval;
    }

    /* Try key2 only if key1 failed */
    if (!(val = get_dbm_entry_as_str(r->pool, f, key1))) {
        val = get_dbm_entry_as_str(r->pool, f, key2);
    }

    apr_dbm_close(f);

    if (val && (grp_colon = ap_strchr(val, ':')) != NULL) {
        char *grp_colon2 = ap_strchr(++grp_colon, ':');

        if (grp_colon2) {
            *grp_colon2 = '\0';
        }
        *out = grp_colon;
    }
    else {
        *out = val;
    }

    return retval;
}

/* Checking ID */
static int dbm_check_auth(request_rec *r)
{
    authz_dbm_config_rec *conf = ap_get_module_config(r->per_dir_config,
                                                      &authz_dbm_module);
    char *user = r->user;
    int m = r->method_number;
    const apr_array_header_t *reqs_arr = ap_requires(r);
    require_line *reqs = reqs_arr ? (require_line *) reqs_arr->elts : NULL;
    register int x;
    const char *t;
    char *w;
    int required_group = 0;
    const char *filegroup = NULL;
    const char *orig_groups = NULL;
    char *reason = NULL;

    if (!conf->grpfile) {
        return DECLINED;
    }

    if (!reqs_arr) {
        return DECLINED;
    }

    for (x = 0; x < reqs_arr->nelts; x++) {

        if (!(reqs[x].method_mask & (AP_METHOD_BIT << m))) {
            continue;
        }

        t = reqs[x].requirement;
        w = ap_getword_white(r->pool, &t);

        if (!strcasecmp(w, "file-group")) {
            filegroup = apr_table_get(r->notes, AUTHZ_GROUP_NOTE);

            if (!filegroup) {
                /* mod_authz_owner is not present or not
                 * authoritative. We are just a helper module for testing
                 * group membership, so we don't care and decline.
                 */
                continue;
            }
        }

        if (!strcasecmp(w, "group") || filegroup) {
            const char *realm = ap_auth_name(r);
            const char *groups;
            char *v;

            /* remember that actually a group is required */
            required_group = 1;

            /* fetch group data from dbm file only once. */
            if (!orig_groups) {
                apr_status_t status;

                status = get_dbm_grp(r, apr_pstrcat(r->pool, user, ":", realm,
                                                    NULL),
                                     user,
                                     conf->grpfile, conf->dbmtype, &groups);

                if (status != APR_SUCCESS) {
                    ap_log_rerror(APLOG_MARK, APLOG_ERR, status, r,
                                  "could not open dbm (type %s) group access "
                                  "file: %s", conf->dbmtype, conf->grpfile);
                    return HTTP_INTERNAL_SERVER_ERROR;
                }

                if (groups == NULL) {
                    /* no groups available, so exit immediately */
                    reason = apr_psprintf(r->pool,
                                          "user doesn't appear in DBM group "
                                          "file (%s).", conf->grpfile);
                    break;
                }

                orig_groups = groups;
            }

            if (filegroup) {
                groups = orig_groups;
                while (groups[0]) {
                    v = ap_getword(r->pool, &groups, ',');
                    if (!strcmp(v, filegroup)) {
                        return OK;
                    }
                }

                if (conf->authoritative) {
                    reason = apr_psprintf(r->pool,
                                          "file group '%s' does not match.",
                                          filegroup);
                    break;
                }

                /* now forget the filegroup, thus alternatively require'd
                   groups get a real chance */
                filegroup = NULL;
            }
            else {
                while (t[0]) {
                    w = ap_getword_white(r->pool, &t);
                    groups = orig_groups;
                    while (groups[0]) {
                        v = ap_getword(r->pool, &groups, ',');
                        if (!strcmp(v, w)) {
                            return OK;
                        }
                    }
                }
            }
        }
    }

    /* No applicable "require group" for this method seen */
    if (!required_group || !conf->authoritative) {
        return DECLINED;
    }

    ap_log_rerror(APLOG_MARK, APLOG_ERR, 0, r,
                  "Authorization of user %s to access %s failed, reason: %s",
                  r->user, r->uri,
                  reason ? reason : "user is not part of the "
                                    "'require'ed group(s).");

    ap_note_auth_failure(r);
    return HTTP_UNAUTHORIZED;
}

static void register_hooks(apr_pool_t *p)
{
    static const char * const aszPre[]={ "mod_authz_owner.c", NULL };

    ap_hook_auth_checker(dbm_check_auth, aszPre, NULL, APR_HOOK_MIDDLE);
}

module AP_MODULE_DECLARE_DATA authz_dbm_module =
{
    STANDARD20_MODULE_STUFF,
    create_authz_dbm_dir_config, /* dir config creater */
    NULL,                        /* dir merger --- default is to override */
    NULL,                        /* server config */
    NULL,                        /* merge server config */
    authz_dbm_cmds,              /* command apr_table_t */
    register_hooks               /* register hooks */
};
