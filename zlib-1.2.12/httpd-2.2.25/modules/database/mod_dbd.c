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

/* Overview of what this is and does:
 * http://www.apache.org/~niq/dbd.html
 * or
 * http://apache.webthing.com/database/
 */

#include "apr_reslist.h"
#include "apr_strings.h"
#include "apr_hash.h"
#include "apr_tables.h"
#include "apr_lib.h"
#include "apr_dbd.h"

#define APR_WANT_MEMFUNC
#define APR_WANT_STRFUNC
#include "apr_want.h"

#include "http_protocol.h"
#include "http_config.h"
#include "http_log.h"
#include "http_request.h"
#include "mod_dbd.h"

extern module AP_MODULE_DECLARE_DATA dbd_module;

/************ svr cfg: manage db connection pool ****************/

#define NMIN_SET     0x1
#define NKEEP_SET    0x2
#define NMAX_SET     0x4
#define EXPTIME_SET  0x8

typedef struct {
    server_rec *server;
    const char *name;
    const char *params;
    int persist;
#if APR_HAS_THREADS
    int nmin;
    int nkeep;
    int nmax;
    int exptime;
    int set;
#endif
    apr_hash_t *queries;
} dbd_cfg_t;

typedef struct dbd_group_t dbd_group_t;

struct dbd_group_t {
    dbd_cfg_t *cfg;
    dbd_group_t *next;
    apr_pool_t *pool;
#if APR_HAS_THREADS
    apr_thread_mutex_t *mutex;
    apr_reslist_t *reslist;
    int destroyed;
#else
    ap_dbd_t *rec;
#endif
};

typedef struct {
    dbd_cfg_t *cfg;
    dbd_group_t *group;
} svr_cfg;

typedef enum { cmd_name, cmd_params, cmd_persist,
               cmd_min, cmd_keep, cmd_max, cmd_exp
} cmd_parts;

static apr_pool_t *config_pool;
static dbd_group_t *group_list;

/* a default DBDriver value that'll generate meaningful error messages */
static const char *const no_dbdriver = "[DBDriver unset]";

/* A default nmin of >0 will help with generating meaningful
 * startup error messages if the database is down.
 */
#define DEFAULT_NMIN 1
#define DEFAULT_NKEEP 2
#define DEFAULT_NMAX 10
#define DEFAULT_EXPTIME 300

static void *create_dbd_config(apr_pool_t *pool, server_rec *s)
{
    svr_cfg *svr = apr_pcalloc(pool, sizeof(svr_cfg));
    dbd_cfg_t *cfg = svr->cfg = apr_pcalloc(pool, sizeof(dbd_cfg_t));

    cfg->server = s;
    cfg->name = no_dbdriver; /* to generate meaningful error messages */
    cfg->params = ""; /* don't risk segfault on misconfiguration */
    cfg->persist = -1;
#if APR_HAS_THREADS
    cfg->nmin = DEFAULT_NMIN;
    cfg->nkeep = DEFAULT_NKEEP;
    cfg->nmax = DEFAULT_NMAX;
    cfg->exptime = DEFAULT_EXPTIME;
#endif
    cfg->queries = apr_hash_make(pool);

    return svr;
}

static void *merge_dbd_config(apr_pool_t *pool, void *basev, void *addv)
{
    dbd_cfg_t *base = ((svr_cfg*) basev)->cfg;
    dbd_cfg_t *add = ((svr_cfg*) addv)->cfg;
    svr_cfg *svr = apr_pcalloc(pool, sizeof(svr_cfg));
    dbd_cfg_t *new = svr->cfg = apr_pcalloc(pool, sizeof(dbd_cfg_t));

    new->server = add->server;
    new->name = (add->name != no_dbdriver) ? add->name : base->name;
    new->params = strcmp(add->params, "") ? add->params : base->params;
    new->persist = (add->persist != -1) ? add->persist : base->persist;
#if APR_HAS_THREADS
    new->nmin = (add->set&NMIN_SET) ? add->nmin : base->nmin;
    new->nkeep = (add->set&NKEEP_SET) ? add->nkeep : base->nkeep;
    new->nmax = (add->set&NMAX_SET) ? add->nmax : base->nmax;
    new->exptime = (add->set&EXPTIME_SET) ? add->exptime : base->exptime;
#endif
    new->queries = apr_hash_overlay(pool, add->queries, base->queries);

    return svr;
}

#define ISINT(val) do {                                                 \
        const char *p;                                                  \
                                                                        \
        for (p = val; *p; ++p) {                                        \
            if (!apr_isdigit(*p)) {                                     \
                return "Argument must be numeric!";                     \
            }                                                           \
        }                                                               \
    } while (0)

static const char *dbd_param(cmd_parms *cmd, void *dconf, const char *val)
{
    const apr_dbd_driver_t *driver = NULL;
    svr_cfg *svr = ap_get_module_config(cmd->server->module_config,
                                        &dbd_module);
    dbd_cfg_t *cfg = svr->cfg;

    switch ((long) cmd->info) {
    case cmd_name:
        cfg->name = val;
        /* loading the driver involves once-only dlloading that is
         * best done at server startup.  This also guarantees that
         * we won't return an error later.
         */
        switch (apr_dbd_get_driver(cmd->pool, cfg->name, &driver)) {
        case APR_ENOTIMPL:
            return apr_psprintf(cmd->pool, "DBD: No driver for %s", cfg->name);
        case APR_EDSOOPEN:
            return apr_psprintf(cmd->pool,
#ifdef NETWARE
                                "DBD: Can't load driver file dbd%s.nlm",
#else
                                "DBD: Can't load driver file apr_dbd_%s.so",
#endif
                                cfg->name);
        case APR_ESYMNOTFOUND:
            return apr_psprintf(cmd->pool,
                                "DBD: Failed to load driver apr_dbd_%s_driver",
                                cfg->name);
        }
        break;
    case cmd_params:
        cfg->params = val;
        break;
#if APR_HAS_THREADS
    case cmd_min:
        ISINT(val);
        cfg->nmin = atoi(val);
        cfg->set |= NMIN_SET;
        break;
    case cmd_keep:
        ISINT(val);
        cfg->nkeep = atoi(val);
        cfg->set |= NKEEP_SET;
        break;
    case cmd_max:
        ISINT(val);
        cfg->nmax = atoi(val);
        cfg->set |= NMAX_SET;
        break;
    case cmd_exp:
        ISINT(val);
        cfg->exptime = atoi(val);
        cfg->set |= EXPTIME_SET;
        break;
#endif
    }

    return NULL;
}

static const char *dbd_param_flag(cmd_parms *cmd, void *dconf, int flag)
{
    svr_cfg *svr = ap_get_module_config(cmd->server->module_config,
                                        &dbd_module);

    switch ((long) cmd->info) {
    case cmd_persist:
        svr->cfg->persist = flag;
        break;
    }

    return NULL;
}

static const char *dbd_prepare(cmd_parms *cmd, void *dconf, const char *query,
                               const char *label)
{
    if (!label) {
        label = query;
        query = "";
    }

    ap_dbd_prepare(cmd->server, query, label);

    return NULL;
}

static const command_rec dbd_cmds[] = {
    AP_INIT_TAKE1("DBDriver", dbd_param, (void*)cmd_name, RSRC_CONF,
                  "SQL Driver"),
    AP_INIT_TAKE1("DBDParams", dbd_param, (void*)cmd_params, RSRC_CONF,
                  "SQL Driver Params"),
    AP_INIT_FLAG("DBDPersist", dbd_param_flag, (void*)cmd_persist, RSRC_CONF,
                 "Use persistent connection/pool"),
    AP_INIT_TAKE12("DBDPrepareSQL", dbd_prepare, NULL, RSRC_CONF,
                   "SQL statement to prepare (or nothing, to override "
                   "statement inherited from main server) and label"),
#if APR_HAS_THREADS
    AP_INIT_TAKE1("DBDMin", dbd_param, (void*)cmd_min, RSRC_CONF,
                  "Minimum number of connections"),
    /* XXX: note that mod_proxy calls this "smax" */
    AP_INIT_TAKE1("DBDKeep", dbd_param, (void*)cmd_keep, RSRC_CONF,
                  "Maximum number of sustained connections"),
    AP_INIT_TAKE1("DBDMax", dbd_param, (void*)cmd_max, RSRC_CONF,
                  "Maximum number of connections"),
    /* XXX: note that mod_proxy calls this "ttl" (time to live) */
    AP_INIT_TAKE1("DBDExptime", dbd_param, (void*)cmd_exp, RSRC_CONF,
                  "Keepalive time for idle connections"),
#endif
    {NULL}
};

static int dbd_pre_config(apr_pool_t *pconf, apr_pool_t *plog,
                          apr_pool_t *ptemp)
{
   config_pool = pconf;
   group_list = NULL;
   return OK;
}

DBD_DECLARE_NONSTD(void) ap_dbd_prepare(server_rec *s, const char *query,
                                        const char *label)
{
    svr_cfg *svr;

    svr = ap_get_module_config(s->module_config, &dbd_module);
    if (!svr) {
         /* some modules may call from within config directive handlers, and
          * if these are called in a server context that contains no mod_dbd
          * config directives, then we have to create our own server config
          */
         svr = create_dbd_config(config_pool, s);
         ap_set_module_config(s->module_config, &dbd_module, svr);
    }

    if (apr_hash_get(svr->cfg->queries, label, APR_HASH_KEY_STRING)
        && strcmp(query, "")) {
        ap_log_error(APLOG_MARK, APLOG_WARNING, 0, s,
                     "conflicting SQL statements with label %s", label);
    }

    apr_hash_set(svr->cfg->queries, label, APR_HASH_KEY_STRING, query);
}

typedef struct {
    const char *label, *query;
} dbd_query_t;

static int dbd_post_config(apr_pool_t *pconf, apr_pool_t *plog,
                           apr_pool_t *ptemp, server_rec *s)
{
    server_rec *sp;
    apr_array_header_t *add_queries = apr_array_make(ptemp, 10,
                                                     sizeof(dbd_query_t));

    for (sp = s; sp; sp = sp->next) {
        svr_cfg *svr = ap_get_module_config(sp->module_config, &dbd_module);
        dbd_cfg_t *cfg = svr->cfg;
        apr_hash_index_t *hi_first = apr_hash_first(ptemp, cfg->queries);
        dbd_group_t *group;

        /* dbd_setup in 2.2.3 and under was causing spurious error messages
         * when dbd isn't configured.  We can stop that with a quick check here
         * together with a similar check in ap_dbd_open (where being
         * unconfigured is a genuine error that must be reported).
         */
        if (cfg->name == no_dbdriver || !cfg->persist) {
            continue;
        }

        for (group = group_list; group; group = group->next) {
            dbd_cfg_t *group_cfg = group->cfg;
            apr_hash_index_t *hi;
            int group_ok = 1;

            if (strcmp(cfg->name, group_cfg->name)
                || strcmp(cfg->params, group_cfg->params)) {
                continue;
            }

#if APR_HAS_THREADS
            if (cfg->nmin != group_cfg->nmin
                || cfg->nkeep != group_cfg->nkeep
                || cfg->nmax != group_cfg->nmax
                || cfg->exptime != group_cfg->exptime) {
                continue;
            }
#endif

            add_queries->nelts = 0;

            for (hi = hi_first; hi; hi = apr_hash_next(hi)) {
                const char *label, *query;
                const char *group_query;

                apr_hash_this(hi, (void*) &label, NULL, (void*) &query);

                group_query = apr_hash_get(group_cfg->queries, label,
                                           APR_HASH_KEY_STRING);

                if (!group_query) {
                    dbd_query_t *add_query = apr_array_push(add_queries);

                    add_query->label = label;
                    add_query->query = query;
                }
                else if (strcmp(query, group_query)) {
                    group_ok = 0;
                    break;
                }
            }

            if (group_ok) {
                int i;

                for (i = 0; i < add_queries->nelts; ++i) {
                    dbd_query_t *add_query = ((dbd_query_t*) add_queries->elts)
                                             + i;

                    apr_hash_set(group_cfg->queries, add_query->label,
                                 APR_HASH_KEY_STRING, add_query->query);
                }

                svr->group = group;
                break;
            }
        }

        if (!svr->group) {
            svr->group = group = apr_pcalloc(pconf, sizeof(dbd_group_t));

            group->cfg = cfg;

            group->next = group_list;
            group_list = group;
        }
    }

    return OK;
}

static apr_status_t dbd_prepared_init(apr_pool_t *pool, dbd_cfg_t *cfg,
                                      ap_dbd_t *rec)
{
    apr_hash_index_t *hi;
    apr_status_t rv = APR_SUCCESS;

    rec->prepared = apr_hash_make(pool);

    for (hi = apr_hash_first(pool, cfg->queries); hi;
         hi = apr_hash_next(hi)) {
        const char *label, *query;
        apr_dbd_prepared_t *stmt;

        apr_hash_this(hi, (void*) &label, NULL, (void*) &query);

        if (!strcmp(query, "")) {
            continue;
        }

        stmt = NULL;
        if (apr_dbd_prepare(rec->driver, pool, rec->handle, query,
                            label, &stmt)) {
            rv = APR_EGENERAL;
        }
        else {
            apr_hash_set(rec->prepared, label, APR_HASH_KEY_STRING, stmt);
        }
    }

    return rv;
}

static apr_status_t dbd_close(void *data)
{
    ap_dbd_t *rec = data;

    return apr_dbd_close(rec->driver, rec->handle);
}

#if APR_HAS_THREADS
static apr_status_t dbd_destruct(void *data, void *params, apr_pool_t *pool)
{
    dbd_group_t *group = params;

    if (!group->destroyed) {
        ap_dbd_t *rec = data;

        apr_pool_destroy(rec->pool);
    }

    return APR_SUCCESS;
}
#endif

/* an apr_reslist_constructor for SQL connections
 * Also use this for opening in non-reslist modes, since it gives
 * us all the error-handling in one place.
 */
static apr_status_t dbd_construct(void **data_ptr,
                                  void *params, apr_pool_t *pool)
{
    dbd_group_t *group = params;
    dbd_cfg_t *cfg = group->cfg;
    apr_pool_t *rec_pool, *prepared_pool;
    ap_dbd_t *rec;
    apr_status_t rv;

    rv = apr_pool_create(&rec_pool, pool);
    if (rv != APR_SUCCESS) {
        ap_log_error(APLOG_MARK, APLOG_CRIT, rv, cfg->server,
                     "DBD: Failed to create memory pool");
        return rv;
    }

    rec = apr_pcalloc(rec_pool, sizeof(ap_dbd_t));

    rec->pool = rec_pool;

    /* The driver is loaded at config time now, so this just checks a hash.
     * If that changes, the driver DSO could be registered to unload against
     * our pool, which is probably not what we want.  Error checking isn't
     * necessary now, but in case that changes in the future ...
     */
    rv = apr_dbd_get_driver(rec->pool, cfg->name, &rec->driver);
    if (rv != APR_SUCCESS) {
        switch (rv) {
        case APR_ENOTIMPL:
            ap_log_error(APLOG_MARK, APLOG_ERR, rv, cfg->server,
                         "DBD: driver for %s not available", cfg->name);
            break;
        case APR_EDSOOPEN:
            ap_log_error(APLOG_MARK, APLOG_ERR, rv, cfg->server,
                         "DBD: can't find driver for %s", cfg->name);
            break;
        case APR_ESYMNOTFOUND:
            ap_log_error(APLOG_MARK, APLOG_ERR, rv, cfg->server,
                         "DBD: driver for %s is invalid or corrupted",
                         cfg->name);
            break;
        default:
            ap_log_error(APLOG_MARK, APLOG_ERR, rv, cfg->server,
                         "DBD: mod_dbd not compatible with APR in get_driver");
            break;
        }

        apr_pool_destroy(rec->pool);
        return rv;
    }

    rv = apr_dbd_open(rec->driver, rec->pool, cfg->params, &rec->handle);
    if (rv != APR_SUCCESS) {
        switch (rv) {
        case APR_EGENERAL:
            ap_log_error(APLOG_MARK, APLOG_ERR, rv, cfg->server,
                         "DBD: Can't connect to %s", cfg->name);
            break;
        default:
            ap_log_error(APLOG_MARK, APLOG_ERR, rv, cfg->server,
                         "DBD: mod_dbd not compatible with APR in open");
            break;
        }

        apr_pool_destroy(rec->pool);
        return rv;
    }

    apr_pool_cleanup_register(rec->pool, rec, dbd_close,
                              apr_pool_cleanup_null);

    /* we use a sub-pool for the prepared statements for each connection so
     * that they will be cleaned up first, before the connection is closed
     */
    rv = apr_pool_create(&prepared_pool, rec->pool);
    if (rv != APR_SUCCESS) {
        ap_log_error(APLOG_MARK, APLOG_CRIT, rv, cfg->server,
                     "DBD: Failed to create memory pool");

        apr_pool_destroy(rec->pool);
        return rv;
    }

    rv = dbd_prepared_init(prepared_pool, cfg, rec);
    if (rv != APR_SUCCESS) {
        const char *errmsg = apr_dbd_error(rec->driver, rec->handle, rv);
        ap_log_error(APLOG_MARK, APLOG_ERR, rv, cfg->server,
                     "DBD: failed to prepare SQL statements: %s",
                     (errmsg ? errmsg : "[???]"));

        apr_pool_destroy(rec->pool);
        return rv;
    }

    *data_ptr = rec;

    return APR_SUCCESS;
}

#if APR_HAS_THREADS
static apr_status_t dbd_destroy(void *data)
{
    dbd_group_t *group = data;

    group->destroyed = 1;

    return APR_SUCCESS;
}

static apr_status_t dbd_setup(server_rec *s, dbd_group_t *group)
{
    dbd_cfg_t *cfg = group->cfg;
    apr_status_t rv;

    /* We create the reslist using a sub-pool of the pool passed to our
     * child_init hook.  No other threads can be here because we're
     * either in the child_init phase or dbd_setup_lock() acquired our mutex.
     * No other threads will use this sub-pool after this, except via
     * reslist calls, which have an internal mutex.
     *
     * We need to short-circuit the cleanup registered internally by
     * apr_reslist_create().  We do this by registering dbd_destroy()
     * as a cleanup afterwards, so that it will run before the reslist's
     * internal cleanup.
     *
     * If we didn't do this, then we could free memory twice when the pool
     * was destroyed.  When apr_pool_destroy() runs, it first destroys all
     * all the per-connection sub-pools created in dbd_construct(), and
     * then it runs the reslist's cleanup.  The cleanup calls dbd_destruct()
     * on each resource, which would then attempt to destroy the sub-pools
     * a second time.
     */
    rv = apr_reslist_create(&group->reslist,
                            cfg->nmin, cfg->nkeep, cfg->nmax,
                            apr_time_from_sec(cfg->exptime),
                            dbd_construct, dbd_destruct, group,
                            group->pool);
    if (rv != APR_SUCCESS) {
        ap_log_error(APLOG_MARK, APLOG_ERR, rv, s,
                     "DBD: failed to initialise");
        return rv;
    }

    apr_pool_cleanup_register(group->pool, group, dbd_destroy,
                              apr_pool_cleanup_null);

    return APR_SUCCESS;
}
#endif

static apr_status_t dbd_setup_init(apr_pool_t *pool, server_rec *s)
{
    dbd_group_t *group;
    apr_status_t rv = APR_SUCCESS;

    for (group = group_list; group; group = group->next) {
        apr_status_t rv2;

        rv2 = apr_pool_create(&group->pool, pool);
        if (rv2 != APR_SUCCESS) {
            ap_log_error(APLOG_MARK, APLOG_CRIT, rv2, s,
                         "DBD: Failed to create reslist cleanup memory pool");
            return rv2;
        }

#if APR_HAS_THREADS
        rv2 = dbd_setup(s, group);
        if (rv2 == APR_SUCCESS) {
            continue;
        }
        else if (rv == APR_SUCCESS) {
            rv = rv2;
        }

        /* we failed, so create a mutex so that subsequent competing callers
         * to ap_dbd_open can serialize themselves while they retry
         */
        rv2 = apr_thread_mutex_create(&group->mutex,
                                      APR_THREAD_MUTEX_DEFAULT, pool);
        if (rv2 != APR_SUCCESS) {
             ap_log_error(APLOG_MARK, APLOG_CRIT, rv2, s,
                          "DBD: Failed to create thread mutex");
             return rv2;
        }
#endif
    }

    return rv;
}

static void dbd_child_init(apr_pool_t *p, server_rec *s)
{
  apr_status_t rv = dbd_setup_init(p, s);
  if (rv) {
    ap_log_error(APLOG_MARK, APLOG_CRIT, rv, s,
                 "DBD: child init failed!");
  }
}

#if APR_HAS_THREADS
static apr_status_t dbd_setup_lock(server_rec *s, dbd_group_t *group)
{
    apr_status_t rv = APR_SUCCESS, rv2;

    /* several threads could be here at the same time, all trying to
     * initialize the reslist because dbd_setup_init failed to do so
     */
    if (!group->mutex) {
        /* we already logged an error when the mutex couldn't be created */
        return APR_EGENERAL;
    }

    rv2 = apr_thread_mutex_lock(group->mutex);
    if (rv2 != APR_SUCCESS) {
        ap_log_error(APLOG_MARK, APLOG_ERR, rv2, s,
                     "DBD: Failed to acquire thread mutex");
        return rv2;
    }

    if (!group->reslist) {
        rv = dbd_setup(s, group);
    }

    rv2 = apr_thread_mutex_unlock(group->mutex);
    if (rv2 != APR_SUCCESS) {
        ap_log_error(APLOG_MARK, APLOG_ERR, rv2, s,
                     "DBD: Failed to release thread mutex");
        if (rv == APR_SUCCESS) {
            rv = rv2;
        }
    }

    return rv;
}
#endif

/* Functions we export for modules to use:
        - open acquires a connection from the pool (opens one if necessary)
        - close releases it back in to the pool
*/
DBD_DECLARE_NONSTD(void) ap_dbd_close(server_rec *s, ap_dbd_t *rec)
{
    svr_cfg *svr = ap_get_module_config(s->module_config, &dbd_module);

    if (!svr->cfg->persist) {
        apr_pool_destroy(rec->pool);
    }
#if APR_HAS_THREADS
    else {
        apr_reslist_release(svr->group->reslist, rec);
    }
#endif
}

static apr_status_t dbd_check(apr_pool_t *pool, server_rec *s, ap_dbd_t *rec)
{
    svr_cfg *svr;
    apr_status_t rv = apr_dbd_check_conn(rec->driver, pool, rec->handle);
    const char *errmsg;

    if ((rv == APR_SUCCESS) || (rv == APR_ENOTIMPL)) {
        return APR_SUCCESS;
    }

    errmsg = apr_dbd_error(rec->driver, rec->handle, rv);
    if (!errmsg) {
        errmsg = "(unknown)";
    }

    svr = ap_get_module_config(s->module_config, &dbd_module);
    ap_log_error(APLOG_MARK, APLOG_ERR, rv, s,
                 "DBD [%s] Error: %s", svr->cfg->name, errmsg);
    return rv;
}

DBD_DECLARE_NONSTD(ap_dbd_t*) ap_dbd_open(apr_pool_t *pool, server_rec *s)
{
    svr_cfg *svr = ap_get_module_config(s->module_config, &dbd_module);
    dbd_group_t *group = svr->group;
    dbd_cfg_t *cfg = svr->cfg;
    ap_dbd_t *rec = NULL;
#if APR_HAS_THREADS
    apr_status_t rv;
#endif

    /* If nothing is configured, we shouldn't be here */
    if (cfg->name == no_dbdriver) {
        ap_log_error(APLOG_MARK, APLOG_ERR, 0, s, "DBD: not configured");
        return NULL;
    }

    if (!cfg->persist) {
        /* Return a once-only connection */
        group = apr_pcalloc(pool, sizeof(dbd_group_t));

        group->cfg = cfg;

        dbd_construct((void*) &rec, group, pool);
        return rec;
    }

#if APR_HAS_THREADS
    if (!group->reslist) {
        if (dbd_setup_lock(s, group) != APR_SUCCESS) {
            return NULL;
        }
    }

    rv = apr_reslist_acquire(group->reslist, (void*) &rec);
    if (rv != APR_SUCCESS) {
        ap_log_error(APLOG_MARK, APLOG_ERR, rv, s,
                     "Failed to acquire DBD connection from pool!");
        return NULL;
    }

    if (dbd_check(pool, s, rec) != APR_SUCCESS) {
        apr_reslist_invalidate(group->reslist, rec);
        return NULL;
    }
#else
    /* If we have a persistent connection and it's good, we'll use it;
     * since this is non-threaded, we can update without a mutex
     */
    rec = group->rec;
    if (rec) {
        if (dbd_check(pool, s, rec) != APR_SUCCESS) {
            apr_pool_destroy(rec->pool);
            rec = NULL;
        }
    }

    /* We don't have a connection right now, so we'll open one */
    if (!rec) {
        dbd_construct((void*) &rec, group, group->pool);
        group->rec = rec;
    }
#endif

    return rec;
}

#if APR_HAS_THREADS
typedef struct {
    ap_dbd_t *rec;
    apr_reslist_t *reslist;
} dbd_acquire_t;

static apr_status_t dbd_release(void *data)
{
    dbd_acquire_t *acq = data;
    apr_reslist_release(acq->reslist, acq->rec);
    return APR_SUCCESS;
}

DBD_DECLARE_NONSTD(ap_dbd_t *) ap_dbd_acquire(request_rec *r)
{
    dbd_acquire_t *acq;

    while (!ap_is_initial_req(r)) {
        if (r->prev) {
            r = r->prev;
        }
        else if (r->main) {
            r = r->main;
        }
    }

    acq = ap_get_module_config(r->request_config, &dbd_module);
    if (!acq) {
        acq = apr_palloc(r->pool, sizeof(dbd_acquire_t));
        acq->rec = ap_dbd_open(r->pool, r->server);
        if (acq->rec) {
            svr_cfg *svr = ap_get_module_config(r->server->module_config,
                                                &dbd_module);

            ap_set_module_config(r->request_config, &dbd_module, acq);
            if (svr->cfg->persist) {
                acq->reslist = svr->group->reslist;
                apr_pool_cleanup_register(r->pool, acq, dbd_release,
                                          apr_pool_cleanup_null);
            }
        }
    }

    return acq->rec;
}

DBD_DECLARE_NONSTD(ap_dbd_t *) ap_dbd_cacquire(conn_rec *c)
{
    dbd_acquire_t *acq = ap_get_module_config(c->conn_config, &dbd_module);

    if (!acq) {
        acq = apr_palloc(c->pool, sizeof(dbd_acquire_t));
        acq->rec = ap_dbd_open(c->pool, c->base_server);
        if (acq->rec) {
            svr_cfg *svr = ap_get_module_config(c->base_server->module_config,
                                                &dbd_module);

            ap_set_module_config(c->conn_config, &dbd_module, acq);
            if (svr->cfg->persist) {
                acq->reslist = svr->group->reslist;
                apr_pool_cleanup_register(c->pool, acq, dbd_release,
                                          apr_pool_cleanup_null);
            }
        }
    }

    return acq->rec;
}
#else
DBD_DECLARE_NONSTD(ap_dbd_t *) ap_dbd_acquire(request_rec *r)
{
    ap_dbd_t *rec;

    while (!ap_is_initial_req(r)) {
        if (r->prev) {
            r = r->prev;
        }
        else if (r->main) {
            r = r->main;
        }
    }

    rec = ap_get_module_config(r->request_config, &dbd_module);
    if (!rec) {
        rec = ap_dbd_open(r->pool, r->server);
        if (rec) {
            ap_set_module_config(r->request_config, &dbd_module, rec);
        }
    }

    return rec;
}

DBD_DECLARE_NONSTD(ap_dbd_t *) ap_dbd_cacquire(conn_rec *c)
{
    ap_dbd_t *rec = ap_get_module_config(c->conn_config, &dbd_module);

    if (!rec) {
        rec = ap_dbd_open(c->pool, c->base_server);
        if (rec) {
            ap_set_module_config(c->conn_config, &dbd_module, rec);
        }
    }

    return rec;
}
#endif

static void dbd_hooks(apr_pool_t *pool)
{
    ap_hook_pre_config(dbd_pre_config, NULL, NULL, APR_HOOK_MIDDLE);
    ap_hook_post_config(dbd_post_config, NULL, NULL, APR_HOOK_MIDDLE);
    ap_hook_child_init(dbd_child_init, NULL, NULL, APR_HOOK_MIDDLE);

    APR_REGISTER_OPTIONAL_FN(ap_dbd_prepare);
    APR_REGISTER_OPTIONAL_FN(ap_dbd_open);
    APR_REGISTER_OPTIONAL_FN(ap_dbd_close);
    APR_REGISTER_OPTIONAL_FN(ap_dbd_acquire);
    APR_REGISTER_OPTIONAL_FN(ap_dbd_cacquire);

    apr_dbd_init(pool);
}

module AP_MODULE_DECLARE_DATA dbd_module = {
    STANDARD20_MODULE_STUFF,
    NULL,
    NULL,
    create_dbd_config,
    merge_dbd_config,
    dbd_cmds,
    dbd_hooks
};

