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

/*
 * Generic DAV lock implementation that a DAV provider can use.
 */

#include "apr.h"
#include "apr_strings.h"
#include "apr_file_io.h"
#include "apr_uuid.h"

#define APR_WANT_MEMFUNC
#include "apr_want.h"

#include "httpd.h"
#include "http_log.h"

#include "mod_dav.h"

#include "locks.h"


/* ---------------------------------------------------------------
 *
 * Lock database primitives
 *
 */

/*
 * LOCK DATABASES
 *
 * Lockdiscovery information is stored in the single lock database specified
 * by the DAVGenericLockDB directive.  Information about this db is stored in
 * the per-dir configuration.
 *
 * KEY
 *
 * The database is keyed by a key_type unsigned char (DAV_TYPE_FNAME)
 * followed by full path.
 *
 * VALUE
 *
 * The value consists of a list of elements.
 *    DIRECT LOCK:     [char      (DAV_LOCK_DIRECT),
 *                      char      (dav_lock_scope),
 *                      char      (dav_lock_type),
 *                      int        depth,
 *                      time_t     expires,
 *                      apr_uuid_t locktoken,
 *                      char[]     owner,
 *                      char[]     auth_user]
 *
 *    INDIRECT LOCK:   [char      (DAV_LOCK_INDIRECT),
 *                      apr_uuid_t locktoken,
 *                      time_t     expires,
 *                      int        key_size,
 *                      char[]     key]
 *       The key is to the collection lock that resulted in this indirect lock
 */

#define DAV_TRUE                    1
#define DAV_FALSE                   0

#define DAV_CREATE_LIST            23
#define DAV_APPEND_LIST            24

/* Stored lock_discovery prefix */
#define DAV_LOCK_DIRECT             1
#define DAV_LOCK_INDIRECT           2

#define DAV_TYPE_FNAME             11

/* Use the opaquelock scheme for locktokens */
struct dav_locktoken {
    apr_uuid_t uuid;
};
#define dav_compare_locktoken(plt1, plt2) \
                memcmp(&(plt1)->uuid, &(plt2)->uuid, sizeof((plt1)->uuid))


/* #################################################################
 * ### keep these structures (internal) or move fully to dav_lock?
 */

/*
 * We need to reliably size the fixed-length portion of
 * dav_lock_discovery; best to separate it into another
 * struct for a convenient sizeof, unless we pack lock_discovery.
 */
typedef struct dav_lock_discovery_fixed
{
    char scope;
    char type;
    int depth;
    time_t timeout;
} dav_lock_discovery_fixed;

typedef struct dav_lock_discovery
{
    struct dav_lock_discovery_fixed f;

    dav_locktoken *locktoken;
    const char *owner;     /* owner field from activelock */
    const char *auth_user; /* authenticated user who created the lock */
    struct dav_lock_discovery *next;
} dav_lock_discovery;

/* Indirect locks represent locks inherited from containing collections.
 * They reference the lock token for the collection the lock is
 * inherited from. A lock provider may also define a key to the
 * inherited lock, for fast datbase lookup. The key is opaque outside
 * the lock provider.
 */
typedef struct dav_lock_indirect
{
    dav_locktoken *locktoken;
    apr_datum_t key;
    struct dav_lock_indirect *next;
    time_t timeout;
} dav_lock_indirect;

/* ################################################################# */

/*
 * Stored direct lock info - full lock_discovery length:
 * prefix + Fixed length + lock token + 2 strings + 2 nulls (one for each
 * string)
 */
#define dav_size_direct(a)  (1 + sizeof(dav_lock_discovery_fixed) \
                               + sizeof(apr_uuid_t) \
                               + ((a)->owner ? strlen((a)->owner) : 0) \
                               + ((a)->auth_user ? strlen((a)->auth_user) : 0) \
                               + 2)

/* Stored indirect lock info - lock token and apr_datum_t */
#define dav_size_indirect(a) (1 + sizeof(apr_uuid_t) \
                                + sizeof(time_t) \
                                + sizeof(int) + (a)->key.dsize)

/*
 * The lockdb structure.
 *
 * The <db> field may be NULL, meaning one of two things:
 * 1) That we have not actually opened the underlying database (yet). The
 *    <opened> field should be false.
 * 2) We opened it readonly and it wasn't present.
 *
 * The delayed opening (determined by <opened>) makes creating a lockdb
 * quick, while deferring the underlying I/O until it is actually required.
 *
 * We export the notion of a lockdb, but hide the details of it. Most
 * implementations will use a database of some kind, but it is certainly
 * possible that alternatives could be used.
 */
struct dav_lockdb_private
{
    request_rec *r; /* for accessing the uuid state */
    apr_pool_t *pool; /* a pool to use */
    const char *lockdb_path; /* where is the lock database? */

    int opened; /* we opened the database */
    apr_dbm_t *db; /* if non-NULL, the lock database */
};

typedef struct
{
    dav_lockdb pub;
    dav_lockdb_private priv;
} dav_lockdb_combined;

/*
 * The private part of the lock structure.
 */
struct dav_lock_private
{
    apr_datum_t key;        /* key into the lock database */
};
typedef struct
{
    dav_lock pub;
    dav_lock_private priv;
    dav_locktoken token;
} dav_lock_combined;

/*
 * This must be forward-declared so the open_lockdb function can use it.
 */
extern const dav_hooks_locks dav_hooks_locks_generic;

static dav_error * dav_generic_dbm_new_error(apr_dbm_t *db, apr_pool_t *p,
                                             apr_status_t status)
{
    int save_errno = errno;
    int errcode;
    const char *errstr;
    dav_error *err;
    char errbuf[200];

    if (status == APR_SUCCESS) {
        return NULL;
    }

    /* There might not be a <db> if we had problems creating it. */
    if (db == NULL) {
        errcode = 1;
        errstr = "Could not open property database.";
    }
    else {
        (void) apr_dbm_geterror(db, &errcode, errbuf, sizeof(errbuf));
        errstr = apr_pstrdup(p, errbuf);
    }

    err = dav_new_error(p, HTTP_INTERNAL_SERVER_ERROR, errcode, errstr);
    err->save_errno = save_errno;
    return err;
}

/* internal function for creating locks */
static dav_lock *dav_generic_alloc_lock(dav_lockdb *lockdb, apr_datum_t key,
                                        const dav_locktoken *locktoken)
{
    dav_lock_combined *comb;

    comb = apr_pcalloc(lockdb->info->pool, sizeof(*comb));
    comb->pub.rectype = DAV_LOCKREC_DIRECT;
    comb->pub.info = &comb->priv;
    comb->priv.key = key;

    if (locktoken == NULL) {
        comb->pub.locktoken = &comb->token;
        apr_uuid_get(&comb->token.uuid);
    }
    else {
        comb->pub.locktoken = locktoken;
    }

    return &comb->pub;
}

/*
 * dav_generic_parse_locktoken
 *
 * Parse an opaquelocktoken URI into a locktoken.
 */
static dav_error * dav_generic_parse_locktoken(apr_pool_t *p,
                                               const char *char_token,
                                               dav_locktoken **locktoken_p)
{
    dav_locktoken *locktoken;

    if (ap_strstr_c(char_token, "opaquelocktoken:") != char_token) {
        return dav_new_error(p,
                             HTTP_BAD_REQUEST, DAV_ERR_LOCK_UNK_STATE_TOKEN,
                             "The lock token uses an unknown State-token "
                             "format and could not be parsed.");
    }
    char_token += 16;

    locktoken = apr_pcalloc(p, sizeof(*locktoken));
    if (apr_uuid_parse(&locktoken->uuid, char_token)) {
        return dav_new_error(p, HTTP_BAD_REQUEST, DAV_ERR_LOCK_PARSE_TOKEN,
                             "The opaquelocktoken has an incorrect format "
                             "and could not be parsed.");
    }

    *locktoken_p = locktoken;
    return NULL;
}

/*
 * dav_generic_format_locktoken
 *
 * Generate the URI for a locktoken
 */
static const char *dav_generic_format_locktoken(apr_pool_t *p,
                                                const dav_locktoken *locktoken)
{
    char buf[APR_UUID_FORMATTED_LENGTH + 1];

    apr_uuid_format(buf, &locktoken->uuid);
    return apr_pstrcat(p, "opaquelocktoken:", buf, NULL);
}

/*
 * dav_generic_compare_locktoken
 *
 * Determine whether two locktokens are the same
 */
static int dav_generic_compare_locktoken(const dav_locktoken *lt1,
                                         const dav_locktoken *lt2)
{
    return dav_compare_locktoken(lt1, lt2);
}

/*
 * dav_generic_really_open_lockdb:
 *
 * If the database hasn't been opened yet, then open the thing.
 */
static dav_error * dav_generic_really_open_lockdb(dav_lockdb *lockdb)
{
    dav_error *err;
    apr_status_t status;

    if (lockdb->info->opened) {
        return NULL;
    }

    status = apr_dbm_open(&lockdb->info->db, lockdb->info->lockdb_path,
                          lockdb->ro ? APR_DBM_READONLY : APR_DBM_RWCREATE,
                          APR_OS_DEFAULT, lockdb->info->pool);

    if (status) {
        err = dav_generic_dbm_new_error(lockdb->info->db, lockdb->info->pool,
                                        status);
        return dav_push_error(lockdb->info->pool,
                              HTTP_INTERNAL_SERVER_ERROR,
                              DAV_ERR_LOCK_OPENDB,
                              "Could not open the lock database.",
                              err);
    }

    /* all right. it is opened now. */
    lockdb->info->opened = 1;

    return NULL;
}

/*
 * dav_generic_open_lockdb:
 *
 * "open" the lock database, as specified in the global server configuration.
 * If force is TRUE, then the database is opened now, rather than lazily.
 *
 * Note that only one can be open read/write.
 */
static dav_error * dav_generic_open_lockdb(request_rec *r, int ro, int force,
                                           dav_lockdb **lockdb)
{
    dav_lockdb_combined *comb;

    comb = apr_pcalloc(r->pool, sizeof(*comb));
    comb->pub.hooks = &dav_hooks_locks_generic;
    comb->pub.ro = ro;
    comb->pub.info = &comb->priv;
    comb->priv.r = r;
    comb->priv.pool = r->pool;

    comb->priv.lockdb_path = dav_generic_get_lockdb_path(r);
    if (comb->priv.lockdb_path == NULL) {
        return dav_new_error(r->pool, HTTP_INTERNAL_SERVER_ERROR,
                             DAV_ERR_LOCK_NO_DB,
                             "A lock database was not specified with the "
                             "DAVGenericLockDB directive. One must be "
                             "specified to use the locking functionality.");
    }

    /* done initializing. return it. */
    *lockdb = &comb->pub;

    if (force) {
        /* ### add a higher-level comment? */
        return dav_generic_really_open_lockdb(*lockdb);
    }

    return NULL;
}

/*
 * dav_generic_close_lockdb:
 *
 * Close it. Duh.
 */
static void dav_generic_close_lockdb(dav_lockdb *lockdb)
{
    if (lockdb->info->db != NULL) {
        apr_dbm_close(lockdb->info->db);
    }
    lockdb->info->opened = 0;
}

/*
 * dav_generic_build_key
 *
 * Given a pathname, build a DAV_TYPE_FNAME lock database key.
 */
static apr_datum_t dav_generic_build_key(apr_pool_t *p,
                                         const dav_resource *resource)
{
    apr_datum_t key;
    const char *pathname = resource->uri;

    /* ### does this allocation have a proper lifetime? need to check */
    /* ### can we use a buffer for this? */

    /* size is TYPE + pathname + null */
    key.dsize = strlen(pathname) + 2;
    key.dptr = apr_palloc(p, key.dsize);
    *key.dptr = DAV_TYPE_FNAME;
    memcpy(key.dptr + 1, pathname, key.dsize - 1);
    if (key.dptr[key.dsize - 2] == '/')
        key.dptr[--key.dsize - 1] = '\0';
    return key;
}

/*
 * dav_generic_lock_expired:  return 1 (true) if the given timeout is in the
 *    past or present (the lock has expired), or 0 (false) if in the future
 *    (the lock has not yet expired).
 */
static int dav_generic_lock_expired(time_t expires)
{
    return expires != DAV_TIMEOUT_INFINITE && time(NULL) >= expires;
}

/*
 * dav_generic_save_lock_record:  Saves the lock information specified in the
 *    direct and indirect lock lists about path into the lock database.
 *    If direct and indirect == NULL, the key is removed.
 */
static dav_error * dav_generic_save_lock_record(dav_lockdb *lockdb,
                                                apr_datum_t key,
                                                dav_lock_discovery *direct,
                                                dav_lock_indirect *indirect)
{
    dav_error *err;
    apr_status_t status;
    apr_datum_t val = { 0 };
    char *ptr;
    dav_lock_discovery *dp = direct;
    dav_lock_indirect *ip = indirect;

#if DAV_DEBUG
    if (lockdb->ro) {
        return dav_new_error(lockdb->info->pool,
                             HTTP_INTERNAL_SERVER_ERROR, 0,
                             "INTERNAL DESIGN ERROR: the lockdb was opened "
                             "readonly, but an attempt to save locks was "
                             "performed.");
    }
#endif

    if ((err = dav_generic_really_open_lockdb(lockdb)) != NULL) {
        /* ### add a higher-level error? */
        return err;
    }

    /* If nothing to save, delete key */
    if (dp == NULL && ip == NULL) {
        /* don't fail if the key is not present */
        /* ### but what about other errors? */
        apr_dbm_delete(lockdb->info->db, key);
        return NULL;
    }

    while(dp) {
        val.dsize += dav_size_direct(dp);
        dp = dp->next;
    }
    while(ip) {
        val.dsize += dav_size_indirect(ip);
        ip = ip->next;
    }

    /* ### can this be apr_palloc() ? */
    /* ### hmmm.... investigate the use of a buffer here */
    ptr = val.dptr = apr_pcalloc(lockdb->info->pool, val.dsize);
    dp  = direct;
    ip  = indirect;

    while(dp) {
        /* Direct lock - lock_discovery struct follows */
        *ptr++ = DAV_LOCK_DIRECT;
        memcpy(ptr, dp, sizeof(dp->f));        /* Fixed portion of struct */
        ptr += sizeof(dp->f);
        memcpy(ptr, dp->locktoken, sizeof(*dp->locktoken));
        ptr += sizeof(*dp->locktoken);
        if (dp->owner == NULL) {
            *ptr++ = '\0';
        }
        else {
            memcpy(ptr, dp->owner, strlen(dp->owner) + 1);
            ptr += strlen(dp->owner) + 1;
        }
        if (dp->auth_user == NULL) {
            *ptr++ = '\0';
        }
        else {
            memcpy(ptr, dp->auth_user, strlen(dp->auth_user) + 1);
            ptr += strlen(dp->auth_user) + 1;
        }

        dp = dp->next;
    }

    while(ip) {
        /* Indirect lock prefix */
        *ptr++ = DAV_LOCK_INDIRECT;

        memcpy(ptr, ip->locktoken, sizeof(*ip->locktoken));
        ptr += sizeof(*ip->locktoken);

        memcpy(ptr, &ip->timeout, sizeof(ip->timeout));
        ptr += sizeof(ip->timeout);

        memcpy(ptr, &ip->key.dsize, sizeof(ip->key.dsize));
        ptr += sizeof(ip->key.dsize);

        memcpy(ptr, ip->key.dptr, ip->key.dsize);
        ptr += ip->key.dsize;

        ip = ip->next;
    }

    if ((status = apr_dbm_store(lockdb->info->db, key, val)) != APR_SUCCESS) {
        /* ### more details? add an error_id? */
        err = dav_generic_dbm_new_error(lockdb->info->db, lockdb->info->pool,
                                        status);
        return dav_push_error(lockdb->info->pool,
                              HTTP_INTERNAL_SERVER_ERROR,
                              DAV_ERR_LOCK_SAVE_LOCK,
                              "Could not save lock information.",
                              err);
    }

    return NULL;
}

/*
 * dav_load_lock_record:  Reads lock information about key from lock db;
 *    creates linked lists of the direct and indirect locks.
 *
 *    If add_method = DAV_APPEND_LIST, the result will be appended to the
 *    head of the direct and indirect lists supplied.
 *
 *    Passive lock removal:  If lock has timed out, it will not be returned.
 *    ### How much "logging" does RFC 2518 require?
 */
static dav_error * dav_generic_load_lock_record(dav_lockdb *lockdb,
                                                apr_datum_t key,
                                                int add_method,
                                                dav_lock_discovery **direct,
                                                dav_lock_indirect **indirect)
{
    apr_pool_t *p = lockdb->info->pool;
    dav_error *err;
    apr_status_t status;
    apr_size_t offset = 0;
    int need_save = DAV_FALSE;
    apr_datum_t val = { 0 };
    dav_lock_discovery *dp;
    dav_lock_indirect *ip;

    if (add_method != DAV_APPEND_LIST) {
        *direct = NULL;
        *indirect = NULL;
    }

    if ((err = dav_generic_really_open_lockdb(lockdb)) != NULL) {
        /* ### add a higher-level error? */
        return err;
    }

    /*
     * If we opened readonly and the db wasn't there, then there are no
     * locks for this resource. Just exit.
     */
    if (lockdb->info->db == NULL) {
        return NULL;
    }

    if ((status = apr_dbm_fetch(lockdb->info->db, key, &val)) != APR_SUCCESS) {
        return dav_generic_dbm_new_error(lockdb->info->db, p, status);
    }

    if (!val.dsize) {
        return NULL;
    }

    while (offset < val.dsize) {
        switch (*(val.dptr + offset++)) {
        case DAV_LOCK_DIRECT:
            /* Create and fill a dav_lock_discovery structure */

            dp = apr_pcalloc(p, sizeof(*dp));

            /* Copy the dav_lock_discovery_fixed portion */
            memcpy(dp, val.dptr + offset, sizeof(dp->f));
            offset += sizeof(dp->f);

            /* Copy the lock token. */
            dp->locktoken = apr_pmemdup(p, val.dptr + offset, sizeof(*dp->locktoken));
            offset += sizeof(*dp->locktoken);

            /* Do we have an owner field? */
            if (*(val.dptr + offset) == '\0') {
                ++offset;
            }
            else {
                apr_size_t len = strlen(val.dptr + offset);
                dp->owner = apr_pstrmemdup(p, val.dptr + offset, len);
                offset += len + 1;
            }

            if (*(val.dptr + offset) == '\0') {
                ++offset;
            }
            else {
                apr_size_t len = strlen(val.dptr + offset);
                dp->auth_user = apr_pstrmemdup(p, val.dptr + offset, len);
                offset += len + 1;
            }

            if (!dav_generic_lock_expired(dp->f.timeout)) {
                dp->next = *direct;
                *direct = dp;
            }
            else {
                need_save = DAV_TRUE;
            }
            break;

        case DAV_LOCK_INDIRECT:
            /* Create and fill a dav_lock_indirect structure */

            ip = apr_pcalloc(p, sizeof(*ip));
            ip->locktoken = apr_pmemdup(p, val.dptr + offset, sizeof(*ip->locktoken));
            offset += sizeof(*ip->locktoken);
            memcpy(&ip->timeout, val.dptr + offset, sizeof(ip->timeout));
            offset += sizeof(ip->timeout);
            /* length of datum */
            ip->key.dsize = *((int *) (val.dptr + offset));
            offset += sizeof(ip->key.dsize);
            ip->key.dptr = apr_pmemdup(p, val.dptr + offset, ip->key.dsize);
            offset += ip->key.dsize;

            if (!dav_generic_lock_expired(ip->timeout)) {
                ip->next = *indirect;
                *indirect = ip;
            }
            else {
                need_save = DAV_TRUE;
            }

            break;

        default:
            apr_dbm_freedatum(lockdb->info->db, val);

            /* ### should use a computed_desc and insert corrupt token data */
            --offset;
            return dav_new_error(p,
                                 HTTP_INTERNAL_SERVER_ERROR,
                                 DAV_ERR_LOCK_CORRUPT_DB,
                                 apr_psprintf(p,
                                             "The lock database was found to "
                                             "be corrupt. offset %"
                                             APR_SIZE_T_FMT ", c=%02x",
                                             offset, val.dptr[offset]));
        }
    }

    apr_dbm_freedatum(lockdb->info->db, val);

    /* Clean up this record if we found expired locks */
    /*
     * ### shouldn't do this if we've been opened READONLY. elide the
     * ### timed-out locks from the response, but don't save that info back
     */
    if (need_save == DAV_TRUE) {
        return dav_generic_save_lock_record(lockdb, key, *direct, *indirect);
    }

    return NULL;
}

/* resolve <indirect>, returning <*direct> */
static dav_error * dav_generic_resolve(dav_lockdb *lockdb,
                                       dav_lock_indirect *indirect,
                                       dav_lock_discovery **direct,
                                       dav_lock_discovery **ref_dp,
                                       dav_lock_indirect **ref_ip)
{
    dav_error *err;
    dav_lock_discovery *dir;
    dav_lock_indirect *ind;

    if ((err = dav_generic_load_lock_record(lockdb, indirect->key,
                                       DAV_CREATE_LIST,
                                       &dir, &ind)) != NULL) {
        /* ### insert a higher-level description? */
        return err;
    }
    if (ref_dp != NULL) {
        *ref_dp = dir;
        *ref_ip = ind;
    }

    for (; dir != NULL; dir = dir->next) {
        if (!dav_compare_locktoken(indirect->locktoken, dir->locktoken)) {
            *direct = dir;
            return NULL;
        }
    }

    /* No match found (but we should have found one!) */

    /* ### use a different description and/or error ID? */
    return dav_new_error(lockdb->info->pool,
                         HTTP_INTERNAL_SERVER_ERROR,
                         DAV_ERR_LOCK_CORRUPT_DB,
                         "The lock database was found to be corrupt. "
                         "An indirect lock's direct lock could not "
                         "be found.");
}

/* ---------------------------------------------------------------
 *
 * Property-related lock functions
 *
 */

/*
 * dav_generic_get_supportedlock:  Returns a static string for all
 *    supportedlock properties. I think we save more returning a static string
 *    than constructing it every time, though it might look cleaner.
 */
static const char *dav_generic_get_supportedlock(const dav_resource *resource)
{
    static const char supported[] = DEBUG_CR
        "<D:lockentry>" DEBUG_CR
        "<D:lockscope><D:exclusive/></D:lockscope>" DEBUG_CR
        "<D:locktype><D:write/></D:locktype>" DEBUG_CR
        "</D:lockentry>" DEBUG_CR
        "<D:lockentry>" DEBUG_CR
        "<D:lockscope><D:shared/></D:lockscope>" DEBUG_CR
        "<D:locktype><D:write/></D:locktype>" DEBUG_CR
        "</D:lockentry>" DEBUG_CR;

    return supported;
}

/* ---------------------------------------------------------------
 *
 * General lock functions
 *
 */

static dav_error * dav_generic_remove_locknull_state(dav_lockdb *lockdb,
                                                 const dav_resource *resource)
{
    /* We don't need to do anything. */
    return NULL;
}

static dav_error * dav_generic_create_lock(dav_lockdb *lockdb,
                                      const dav_resource *resource,
                                      dav_lock **lock)
{
    apr_datum_t key;

    key = dav_generic_build_key(lockdb->info->pool, resource);

    *lock = dav_generic_alloc_lock(lockdb, key, NULL);

    (*lock)->is_locknull = !resource->exists;

    return NULL;
}

static dav_error * dav_generic_get_locks(dav_lockdb *lockdb,
                                         const dav_resource *resource,
                                         int calltype,
                                         dav_lock **locks)
{
    apr_pool_t *p = lockdb->info->pool;
    apr_datum_t key;
    dav_error *err;
    dav_lock *lock = NULL;
    dav_lock *newlock;
    dav_lock_discovery *dp;
    dav_lock_indirect *ip;

#if DAV_DEBUG
    if (calltype == DAV_GETLOCKS_COMPLETE) {
        return dav_new_error(lockdb->info->pool,
                             HTTP_INTERNAL_SERVER_ERROR, 0,
                             "INTERNAL DESIGN ERROR: DAV_GETLOCKS_COMPLETE "
                             "is not yet supported");
    }
#endif

    key = dav_generic_build_key(p, resource);
    if ((err = dav_generic_load_lock_record(lockdb, key, DAV_CREATE_LIST,
                                            &dp, &ip)) != NULL) {
        /* ### push a higher-level desc? */
        return err;
    }

    /* copy all direct locks to the result list */
    for (; dp != NULL; dp = dp->next) {
        newlock = dav_generic_alloc_lock(lockdb, key, dp->locktoken);
        newlock->is_locknull = !resource->exists;
        newlock->scope = dp->f.scope;
        newlock->type = dp->f.type;
        newlock->depth = dp->f.depth;
        newlock->timeout = dp->f.timeout;
        newlock->owner = dp->owner;
        newlock->auth_user = dp->auth_user;

        /* hook into the result list */
        newlock->next = lock;
        lock = newlock;
    }

    /* copy all the indirect locks to the result list. resolve as needed. */
    for (; ip != NULL; ip = ip->next) {
        newlock = dav_generic_alloc_lock(lockdb, ip->key, ip->locktoken);
        newlock->is_locknull = !resource->exists;

        if (calltype == DAV_GETLOCKS_RESOLVED) {
            err = dav_generic_resolve(lockdb, ip, &dp, NULL, NULL);
            if (err != NULL) {
                /* ### push a higher-level desc? */
                return err;
            }

            newlock->scope = dp->f.scope;
            newlock->type = dp->f.type;
            newlock->depth = dp->f.depth;
            newlock->timeout = dp->f.timeout;
            newlock->owner = dp->owner;
            newlock->auth_user = dp->auth_user;
        }
        else {
            /* DAV_GETLOCKS_PARTIAL */
            newlock->rectype = DAV_LOCKREC_INDIRECT_PARTIAL;
        }

        /* hook into the result list */
        newlock->next = lock;
        lock = newlock;
    }

    *locks = lock;
    return NULL;
}

static dav_error * dav_generic_find_lock(dav_lockdb *lockdb,
                                         const dav_resource *resource,
                                         const dav_locktoken *locktoken,
                                         int partial_ok,
                                         dav_lock **lock)
{
    dav_error *err;
    apr_datum_t key;
    dav_lock_discovery *dp;
    dav_lock_indirect *ip;

    *lock = NULL;

    key = dav_generic_build_key(lockdb->info->pool, resource);
    if ((err = dav_generic_load_lock_record(lockdb, key, DAV_CREATE_LIST,
                                       &dp, &ip)) != NULL) {
        /* ### push a higher-level desc? */
        return err;
    }

    for (; dp != NULL; dp = dp->next) {
        if (!dav_compare_locktoken(locktoken, dp->locktoken)) {
            *lock = dav_generic_alloc_lock(lockdb, key, locktoken);
            (*lock)->is_locknull = !resource->exists;
            (*lock)->scope = dp->f.scope;
            (*lock)->type = dp->f.type;
            (*lock)->depth = dp->f.depth;
            (*lock)->timeout = dp->f.timeout;
            (*lock)->owner = dp->owner;
            (*lock)->auth_user = dp->auth_user;
            return NULL;
        }
    }

    for (; ip != NULL; ip = ip->next) {
        if (!dav_compare_locktoken(locktoken, ip->locktoken)) {
            *lock = dav_generic_alloc_lock(lockdb, ip->key, locktoken);
            (*lock)->is_locknull = !resource->exists;

            /* ### nobody uses the resolving right now! */
            if (partial_ok) {
                (*lock)->rectype = DAV_LOCKREC_INDIRECT_PARTIAL;
            }
            else {
                (*lock)->rectype = DAV_LOCKREC_INDIRECT;
                if ((err = dav_generic_resolve(lockdb, ip, &dp,
                                          NULL, NULL)) != NULL) {
                    /* ### push a higher-level desc? */
                    return err;
                }
                (*lock)->scope = dp->f.scope;
                (*lock)->type = dp->f.type;
                (*lock)->depth = dp->f.depth;
                (*lock)->timeout = dp->f.timeout;
                (*lock)->owner = dp->owner;
                (*lock)->auth_user = dp->auth_user;
            }
            return NULL;
        }
    }

    return NULL;
}

static dav_error * dav_generic_has_locks(dav_lockdb *lockdb,
                                         const dav_resource *resource,
                                         int *locks_present)
{
    dav_error *err;
    apr_datum_t key;

    *locks_present = 0;

    if ((err = dav_generic_really_open_lockdb(lockdb)) != NULL) {
        /* ### insert a higher-level error description */
        return err;
    }

    /*
     * If we opened readonly and the db wasn't there, then there are no
     * locks for this resource. Just exit.
     */
    if (lockdb->info->db == NULL)
        return NULL;

    key = dav_generic_build_key(lockdb->info->pool, resource);

    *locks_present = apr_dbm_exists(lockdb->info->db, key);

    return NULL;
}

static dav_error * dav_generic_append_locks(dav_lockdb *lockdb,
                                            const dav_resource *resource,
                                            int make_indirect,
                                            const dav_lock *lock)
{
    apr_pool_t *p = lockdb->info->pool;
    dav_error *err;
    dav_lock_indirect *ip;
    dav_lock_discovery *dp;
    apr_datum_t key;

    key = dav_generic_build_key(lockdb->info->pool, resource);

    err = dav_generic_load_lock_record(lockdb, key, 0, &dp, &ip);
    if (err != NULL) {
        /* ### maybe add in a higher-level description */
        return err;
    }

    /*
     * ### when we store the lock more directly, we need to update
     * ### lock->rectype and lock->is_locknull
     */

    if (make_indirect) {
        for (; lock != NULL; lock = lock->next) {

            /* ### this works for any <lock> rectype */
            dav_lock_indirect *newi = apr_pcalloc(p, sizeof(*newi));

            /* ### shut off the const warning for now */
            newi->locktoken = (dav_locktoken *)lock->locktoken;
            newi->timeout   = lock->timeout;
            newi->key       = lock->info->key;
            newi->next      = ip;
            ip              = newi;
        }
    }
    else {
        for (; lock != NULL; lock = lock->next) {
            /* create and link in the right kind of lock */

            if (lock->rectype == DAV_LOCKREC_DIRECT) {
                dav_lock_discovery *newd = apr_pcalloc(p, sizeof(*newd));

                newd->f.scope = lock->scope;
                newd->f.type = lock->type;
                newd->f.depth = lock->depth;
                newd->f.timeout = lock->timeout;
                /* ### shut off the const warning for now */
                newd->locktoken = (dav_locktoken *)lock->locktoken;
                newd->owner = lock->owner;
                newd->auth_user = lock->auth_user;
                newd->next = dp;
                dp = newd;
            }
            else {
                /* DAV_LOCKREC_INDIRECT(_PARTIAL) */

                dav_lock_indirect *newi = apr_pcalloc(p, sizeof(*newi));

                /* ### shut off the const warning for now */
                newi->locktoken = (dav_locktoken *)lock->locktoken;
                newi->key       = lock->info->key;
                newi->next      = ip;
                ip              = newi;
            }
        }
    }

    if ((err = dav_generic_save_lock_record(lockdb, key, dp, ip)) != NULL) {
        /* ### maybe add a higher-level description */
        return err;
    }

    return NULL;
}

static dav_error * dav_generic_remove_lock(dav_lockdb *lockdb,
                                           const dav_resource *resource,
                                           const dav_locktoken *locktoken)
{
    dav_error *err;
    dav_lock_discovery *dh = NULL;
    dav_lock_indirect *ih = NULL;
    apr_datum_t key;

    key = dav_generic_build_key(lockdb->info->pool, resource);

    if (locktoken != NULL) {
        dav_lock_discovery *dp;
        dav_lock_discovery *dprev = NULL;
        dav_lock_indirect *ip;
        dav_lock_indirect *iprev = NULL;

        if ((err = dav_generic_load_lock_record(lockdb, key, DAV_CREATE_LIST,
                                           &dh, &ih)) != NULL) {
            /* ### maybe add a higher-level description */
            return err;
        }

        for (dp = dh; dp != NULL; dp = dp->next) {
            if (dav_compare_locktoken(locktoken, dp->locktoken) == 0) {
                if (dprev)
                    dprev->next = dp->next;
                else
                    dh = dh->next;
            }
            dprev = dp;
        }

        for (ip = ih; ip != NULL; ip = ip->next) {
            if (dav_compare_locktoken(locktoken, ip->locktoken) == 0) {
                if (iprev)
                    iprev->next = ip->next;
                else
                    ih = ih->next;
            }
            iprev = ip;
        }

    }

    /* save the modified locks, or remove all locks (dh=ih=NULL). */
    if ((err = dav_generic_save_lock_record(lockdb, key, dh, ih)) != NULL) {
        /* ### maybe add a higher-level description */
        return err;
    }

    return NULL;
}

static int dav_generic_do_refresh(dav_lock_discovery *dp,
                                  const dav_locktoken_list *ltl,
                                  time_t new_time)
{
    int dirty = 0;

    for (; ltl != NULL; ltl = ltl->next) {
        if (dav_compare_locktoken(dp->locktoken, ltl->locktoken) == 0)
        {
            dp->f.timeout = new_time;
            dirty = 1;
        }
    }

    return dirty;
}

static dav_error * dav_generic_refresh_locks(dav_lockdb *lockdb,
                                             const dav_resource *resource,
                                             const dav_locktoken_list *ltl,
                                             time_t new_time,
                                             dav_lock **locks)
{
    dav_error *err;
    apr_datum_t key;
    dav_lock_discovery *dp;
    dav_lock_discovery *dp_scan;
    dav_lock_indirect *ip;
    int dirty = 0;
    dav_lock *newlock;

    *locks = NULL;

    key = dav_generic_build_key(lockdb->info->pool, resource);
    if ((err = dav_generic_load_lock_record(lockdb, key, DAV_CREATE_LIST,
                                            &dp, &ip)) != NULL) {
        /* ### maybe add in a higher-level description */
        return err;
    }

    /* ### we should be refreshing direct AND (resolved) indirect locks! */

    /* refresh all of the direct locks on this resource */
    for (dp_scan = dp; dp_scan != NULL; dp_scan = dp_scan->next) {
        if (dav_generic_do_refresh(dp_scan, ltl, new_time)) {
            /* the lock was refreshed. return the lock. */
            newlock = dav_generic_alloc_lock(lockdb, key, dp_scan->locktoken);
            newlock->is_locknull = !resource->exists;
            newlock->scope = dp_scan->f.scope;
            newlock->type = dp_scan->f.type;
            newlock->depth = dp_scan->f.depth;
            newlock->timeout = dp_scan->f.timeout;
            newlock->owner = dp_scan->owner;
            newlock->auth_user = dp_scan->auth_user;

            newlock->next = *locks;
            *locks = newlock;

            dirty = 1;
        }
    }

    /* if we refreshed any locks, then save them back. */
    if (dirty
        && (err = dav_generic_save_lock_record(lockdb, key, dp, ip)) != NULL) {
        /* ### maybe add in a higher-level description */
        return err;
    }

    /* for each indirect lock, find its direct lock and refresh it. */
    for (; ip != NULL; ip = ip->next) {
        dav_lock_discovery *ref_dp;
        dav_lock_indirect *ref_ip;

        if ((err = dav_generic_resolve(lockdb, ip, &dp_scan,
                                       &ref_dp, &ref_ip)) != NULL) {
            /* ### push a higher-level desc? */
            return err;
        }
        if (dav_generic_do_refresh(dp_scan, ltl, new_time)) {
            /* the lock was refreshed. return the lock. */
            newlock = dav_generic_alloc_lock(lockdb, ip->key, dp->locktoken);
            newlock->is_locknull = !resource->exists;
            newlock->scope = dp->f.scope;
            newlock->type = dp->f.type;
            newlock->depth = dp->f.depth;
            newlock->timeout = dp->f.timeout;
            newlock->owner = dp->owner;
            newlock->auth_user = dp_scan->auth_user;

            newlock->next = *locks;
            *locks = newlock;

            /* save the (resolved) direct lock back */
            if ((err = dav_generic_save_lock_record(lockdb, ip->key, ref_dp,
                                                    ref_ip)) != NULL) {
                /* ### push a higher-level desc? */
                return err;
            }
        }
    }

    return NULL;
}


const dav_hooks_locks dav_hooks_locks_generic =
{
    dav_generic_get_supportedlock,
    dav_generic_parse_locktoken,
    dav_generic_format_locktoken,
    dav_generic_compare_locktoken,
    dav_generic_open_lockdb,
    dav_generic_close_lockdb,
    dav_generic_remove_locknull_state,
    dav_generic_create_lock,
    dav_generic_get_locks,
    dav_generic_find_lock,
    dav_generic_has_locks,
    dav_generic_append_locks,
    dav_generic_remove_lock,
    dav_generic_refresh_locks,
    NULL, /* lookup_resource */

    NULL /* ctx */
};
