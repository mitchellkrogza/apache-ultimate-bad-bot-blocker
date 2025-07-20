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
 * mod_ext_filter allows Unix-style filters to filter http content.
 */

#include "httpd.h"
#include "http_config.h"
#include "http_log.h"
#include "http_protocol.h"
#define CORE_PRIVATE
#include "http_core.h"
#include "apr_buckets.h"
#include "util_filter.h"
#include "util_script.h"
#include "util_time.h"
#include "apr_strings.h"
#include "apr_hash.h"
#include "apr_lib.h"
#include "apr_poll.h"
#define APR_WANT_STRFUNC
#include "apr_want.h"

typedef struct ef_server_t {
    apr_pool_t *p;
    apr_hash_t *h;
} ef_server_t;

typedef struct ef_filter_t {
    const char *name;
    enum {INPUT_FILTER=1, OUTPUT_FILTER} mode;
    ap_filter_type ftype;
    const char *command;
    const char *enable_env;
    const char *disable_env;
    char **args;
    const char *intype;             /* list of IMTs we process (well, just one for now) */
#define INTYPE_ALL (char *)1
    const char *outtype;            /* IMT of filtered output */
#define OUTTYPE_UNCHANGED (char *)1
    int preserves_content_length;
} ef_filter_t;

typedef struct ef_dir_t {
    int debug;
    int log_stderr;
    int onfail;
} ef_dir_t;

typedef struct ef_ctx_t {
    apr_pool_t *p;
    apr_proc_t *proc;
    apr_procattr_t *procattr;
    ef_dir_t *dc;
    ef_filter_t *filter;
    int noop;
#if APR_FILES_AS_SOCKETS
    apr_pollset_t *pollset;
#endif
} ef_ctx_t;

module AP_MODULE_DECLARE_DATA ext_filter_module;
static const server_rec *main_server;

static apr_status_t ef_output_filter(ap_filter_t *, apr_bucket_brigade *);
static apr_status_t ef_input_filter(ap_filter_t *, apr_bucket_brigade *,
                                    ap_input_mode_t, apr_read_type_e,
                                    apr_off_t);

#define DBGLVL_SHOWOPTIONS         1
#define DBGLVL_GORY                9

#define ERRFN_USERDATA_KEY         "EXTFILTCHILDERRFN"

static void *create_ef_dir_conf(apr_pool_t *p, char *dummy)
{
    ef_dir_t *dc = (ef_dir_t *)apr_pcalloc(p, sizeof(ef_dir_t));

    dc->debug = -1;
    dc->log_stderr = -1;
    dc->onfail = -1;

    return dc;
}

static void *create_ef_server_conf(apr_pool_t *p, server_rec *s)
{
    ef_server_t *conf;

    conf = (ef_server_t *)apr_pcalloc(p, sizeof(ef_server_t));
    conf->p = p;
    conf->h = apr_hash_make(conf->p);
    return conf;
}

static void *merge_ef_dir_conf(apr_pool_t *p, void *basev, void *overridesv)
{
    ef_dir_t *a = (ef_dir_t *)apr_pcalloc (p, sizeof(ef_dir_t));
    ef_dir_t *base = (ef_dir_t *)basev, *over = (ef_dir_t *)overridesv;

    if (over->debug != -1) {        /* if admin coded something... */
        a->debug = over->debug;
    }
    else {
        a->debug = base->debug;
    }

    if (over->log_stderr != -1) {   /* if admin coded something... */
        a->log_stderr = over->log_stderr;
    }
    else {
        a->log_stderr = base->log_stderr;
    }

    if (over->onfail != -1) {   /* if admin coded something... */
        a->onfail = over->onfail;
    }
    else {
        a->onfail = base->onfail;
    }

    return a;
}

static const char *add_options(cmd_parms *cmd, void *in_dc,
                               const char *arg)
{
    ef_dir_t *dc = in_dc;

    if (!strncasecmp(arg, "DebugLevel=", 11)) {
        dc->debug = atoi(arg + 11);
    }
    else if (!strcasecmp(arg, "LogStderr")) {
        dc->log_stderr = 1;
    }
    else if (!strcasecmp(arg, "NoLogStderr")) {
        dc->log_stderr = 0;
    }
    else if (!strcasecmp(arg, "Onfail=remove")) {
        dc->onfail = 1;
    }
    else if (!strcasecmp(arg, "Onfail=abort")) {
        dc->onfail = 0;
    }
    else {
        return apr_pstrcat(cmd->temp_pool,
                           "Invalid ExtFilterOptions option: ",
                           arg,
                           NULL);
    }

    return NULL;
}

static const char *parse_cmd(apr_pool_t *p, const char **args, ef_filter_t *filter)
{
    if (**args == '"') {
        const char *start = *args + 1;
        char *parms;
        int escaping = 0;
        apr_status_t rv;

        ++*args; /* move past leading " */
        /* find true end of args string (accounting for escaped quotes) */
        while (**args && (**args != '"' || (**args == '"' && escaping))) {
            if (escaping) {
                escaping = 0;
            }
            else if (**args == '\\') {
                escaping = 1;
            }
            ++*args;
        }
        if (**args != '"') {
            return "Expected cmd= delimiter";
        }
        /* copy *just* the arg string for parsing, */
        parms = apr_pstrndup(p, start, *args - start);
        ++*args; /* move past trailing " */

        /* parse and tokenize the args. */
        rv = apr_tokenize_to_argv(parms, &(filter->args), p);
        if (rv != APR_SUCCESS) {
            return "cmd= parse error";
        }
    }
    else
    {
        /* simple path */
        /* Allocate space for two argv pointers and parse the args. */
        filter->args = (char **)apr_palloc(p, 2 * sizeof(char *));
        filter->args[0] = ap_getword_white(p, args);
        filter->args[1] = NULL; /* end of args */
    }
    if (!filter->args[0]) {
        return "Invalid cmd= parameter";
    }
    filter->command = filter->args[0];

    return NULL;
}

static const char *define_filter(cmd_parms *cmd, void *dummy, const char *args)
{
    ef_server_t *conf = ap_get_module_config(cmd->server->module_config,
                                             &ext_filter_module);
    const char *token;
    const char *name;
    char *normalized_name;
    ef_filter_t *filter;

    name = ap_getword_white(cmd->pool, &args);
    if (!name) {
        return "Filter name not found";
    }

    /* During request processing, we find information about the filter
     * by looking up the filter name provided by core server in our
     * hash table.  But the core server has normalized the filter
     * name by converting it to lower case.  Thus, when adding the
     * filter to our hash table we have to use lower case as well.
     */
    normalized_name = apr_pstrdup(cmd->pool, name);
    ap_str_tolower(normalized_name);

    if (apr_hash_get(conf->h, normalized_name, APR_HASH_KEY_STRING)) {
        return apr_psprintf(cmd->pool, "ExtFilter %s is already defined",
                            name);
    }

    filter = (ef_filter_t *)apr_pcalloc(conf->p, sizeof(ef_filter_t));
    filter->name = name;
    filter->mode = OUTPUT_FILTER;
    filter->ftype = AP_FTYPE_RESOURCE;
    apr_hash_set(conf->h, normalized_name, APR_HASH_KEY_STRING, filter);

    while (*args) {
        while (apr_isspace(*args)) {
            ++args;
        }

        /* Nasty parsing...  I wish I could simply use ap_getword_white()
         * here and then look at the token, but ap_getword_white() doesn't
         * do the right thing when we have cmd="word word word"
         */
        if (!strncasecmp(args, "preservescontentlength", 22)) {
            token = ap_getword_white(cmd->pool, &args);
            if (!strcasecmp(token, "preservescontentlength")) {
                filter->preserves_content_length = 1;
            }
            else {
                return apr_psprintf(cmd->pool,
                                    "mangled argument `%s'",
                                    token);
            }
            continue;
        }

        if (!strncasecmp(args, "mode=", 5)) {
            args += 5;
            token = ap_getword_white(cmd->pool, &args);
            if (!strcasecmp(token, "output")) {
                filter->mode = OUTPUT_FILTER;
            }
            else if (!strcasecmp(token, "input")) {
                filter->mode = INPUT_FILTER;
            }
            else {
                return apr_psprintf(cmd->pool, "Invalid mode: `%s'",
                                    token);
            }
            continue;
        }

        if (!strncasecmp(args, "ftype=", 6)) {
            args += 6;
            token = ap_getword_white(cmd->pool, &args);
            filter->ftype = atoi(token);
            continue;
        }

        if (!strncasecmp(args, "enableenv=", 10)) {
            args += 10;
            token = ap_getword_white(cmd->pool, &args);
            filter->enable_env = token;
            continue;
        }

        if (!strncasecmp(args, "disableenv=", 11)) {
            args += 11;
            token = ap_getword_white(cmd->pool, &args);
            filter->disable_env = token;
            continue;
        }

        if (!strncasecmp(args, "intype=", 7)) {
            args += 7;
            filter->intype = ap_getword_white(cmd->pool, &args);
            continue;
        }

        if (!strncasecmp(args, "outtype=", 8)) {
            args += 8;
            filter->outtype = ap_getword_white(cmd->pool, &args);
            continue;
        }

        if (!strncasecmp(args, "cmd=", 4)) {
            args += 4;
            if ((token = parse_cmd(cmd->pool, &args, filter))) {
                return token;
            }
            continue;
        }

        return apr_psprintf(cmd->pool, "Unexpected parameter: `%s'",
                            args);
    }

    /* parsing is done...  register the filter
     */
    if (filter->mode == OUTPUT_FILTER) {
        /* XXX need a way to ensure uniqueness among all filters */
        ap_register_output_filter(filter->name, ef_output_filter, NULL, filter->ftype);
    }
    else if (filter->mode == INPUT_FILTER) {
        /* XXX need a way to ensure uniqueness among all filters */
        ap_register_input_filter(filter->name, ef_input_filter, NULL, filter->ftype);
    }
    else {
        ap_assert(1 != 1); /* we set the field wrong somehow */
    }

    return NULL;
}

static const command_rec cmds[] =
{
    AP_INIT_ITERATE("ExtFilterOptions",
                    add_options,
                    NULL,
                    ACCESS_CONF, /* same as SetInputFilter/SetOutputFilter */
                    "valid options: DebugLevel=n, LogStderr, NoLogStderr"),
    AP_INIT_RAW_ARGS("ExtFilterDefine",
                     define_filter,
                     NULL,
                     RSRC_CONF,
                     "Define an external filter"),
    {NULL}
};

static int ef_init(apr_pool_t *p, apr_pool_t *plog, apr_pool_t *ptemp, server_rec *main_s)
{
    main_server = main_s;
    return OK;
}

static void register_hooks(apr_pool_t *p)
{
    ap_hook_post_config(ef_init, NULL, NULL, APR_HOOK_MIDDLE);
}

static apr_status_t set_resource_limits(request_rec *r,
                                        apr_procattr_t *procattr)
{
#if defined(RLIMIT_CPU)  || defined(RLIMIT_NPROC) || \
    defined(RLIMIT_DATA) || defined(RLIMIT_VMEM) || defined (RLIMIT_AS)
    core_dir_config *conf =
        (core_dir_config *)ap_get_module_config(r->per_dir_config,
                                                &core_module);
    apr_status_t rv;

#ifdef RLIMIT_CPU
    rv = apr_procattr_limit_set(procattr, APR_LIMIT_CPU, conf->limit_cpu);
    ap_assert(rv == APR_SUCCESS); /* otherwise, we're out of sync with APR */
#endif
#if defined(RLIMIT_DATA) || defined(RLIMIT_VMEM) || defined(RLIMIT_AS)
    rv = apr_procattr_limit_set(procattr, APR_LIMIT_MEM, conf->limit_mem);
    ap_assert(rv == APR_SUCCESS); /* otherwise, we're out of sync with APR */
#endif
#ifdef RLIMIT_NPROC
    rv = apr_procattr_limit_set(procattr, APR_LIMIT_NPROC, conf->limit_nproc);
    ap_assert(rv == APR_SUCCESS); /* otherwise, we're out of sync with APR */
#endif

#endif /* if at least one limit defined */

    return APR_SUCCESS;
}

static apr_status_t ef_close_file(void *vfile)
{
    return apr_file_close(vfile);
}

static void child_errfn(apr_pool_t *pool, apr_status_t err, const char *description)
{
    request_rec *r;
    void *vr;
    apr_file_t *stderr_log;
    char errbuf[200];
    char time_str[APR_CTIME_LEN];

    apr_pool_userdata_get(&vr, ERRFN_USERDATA_KEY, pool);
    r = vr;
    apr_file_open_stderr(&stderr_log, pool);
    ap_recent_ctime(time_str, apr_time_now());
    apr_file_printf(stderr_log,
                    "[%s] [client %s] mod_ext_filter (%d)%s: %s\n",
                    time_str,
                    r->connection->remote_ip,
                    err,
                    apr_strerror(err, errbuf, sizeof(errbuf)),
                    description);
}

/* init_ext_filter_process: get the external filter process going
 * This is per-filter-instance (i.e., per-request) initialization.
 */
static apr_status_t init_ext_filter_process(ap_filter_t *f)
{
    ef_ctx_t *ctx = f->ctx;
    apr_status_t rc;
    ef_dir_t *dc = ctx->dc;
    const char * const *env;

    ctx->proc = apr_pcalloc(ctx->p, sizeof(*ctx->proc));

    rc = apr_procattr_create(&ctx->procattr, ctx->p);
    ap_assert(rc == APR_SUCCESS);

    rc = apr_procattr_io_set(ctx->procattr,
                            APR_CHILD_BLOCK,
                            APR_CHILD_BLOCK,
                            APR_CHILD_BLOCK);
    ap_assert(rc == APR_SUCCESS);

    rc = set_resource_limits(f->r, ctx->procattr);
    ap_assert(rc == APR_SUCCESS);

    if (dc->log_stderr > 0) {
        rc = apr_procattr_child_err_set(ctx->procattr,
                                      f->r->server->error_log, /* stderr in child */
                                      NULL);
        ap_assert(rc == APR_SUCCESS);
    }

    rc = apr_procattr_child_errfn_set(ctx->procattr, child_errfn);
    ap_assert(rc == APR_SUCCESS);
    apr_pool_userdata_set(f->r, ERRFN_USERDATA_KEY, apr_pool_cleanup_null, ctx->p);

    rc = apr_procattr_error_check_set(ctx->procattr, 1);
    if (rc != APR_SUCCESS) {
        return rc;
    }

    /* add standard CGI variables as well as DOCUMENT_URI, DOCUMENT_PATH_INFO,
     * and QUERY_STRING_UNESCAPED
     */
    ap_add_cgi_vars(f->r);
    ap_add_common_vars(f->r);
    apr_table_setn(f->r->subprocess_env, "DOCUMENT_URI", f->r->uri);
    apr_table_setn(f->r->subprocess_env, "DOCUMENT_PATH_INFO", f->r->path_info);
    if (f->r->args) {
            /* QUERY_STRING is added by ap_add_cgi_vars */
        char *arg_copy = apr_pstrdup(f->r->pool, f->r->args);
        ap_unescape_url(arg_copy);
        apr_table_setn(f->r->subprocess_env, "QUERY_STRING_UNESCAPED",
                       ap_escape_shell_cmd(f->r->pool, arg_copy));
    }

    env = (const char * const *) ap_create_environment(ctx->p,
                                                       f->r->subprocess_env);

    rc = apr_proc_create(ctx->proc,
                            ctx->filter->command,
                            (const char * const *)ctx->filter->args,
                            env, /* environment */
                            ctx->procattr,
                            ctx->p);
    if (rc != APR_SUCCESS) {
        ap_log_rerror(APLOG_MARK, APLOG_ERR, rc, f->r,
                      "couldn't create child process to run `%s'",
                      ctx->filter->command);
        return rc;
    }

    apr_pool_note_subprocess(ctx->p, ctx->proc, APR_KILL_AFTER_TIMEOUT);

    /* We don't want the handle to the child's stdin inherited by any
     * other processes created by httpd.  Otherwise, when we close our
     * handle, the child won't see EOF because another handle will still
     * be open.
     */

    apr_pool_cleanup_register(ctx->p, ctx->proc->in,
                         apr_pool_cleanup_null, /* other mechanism */
                         ef_close_file);

#if APR_FILES_AS_SOCKETS
    {
        apr_pollfd_t pfd = { 0 };

        rc = apr_pollset_create(&ctx->pollset, 2, ctx->p, 0);
        ap_assert(rc == APR_SUCCESS);

        pfd.p         = ctx->p;
        pfd.desc_type = APR_POLL_FILE;
        pfd.reqevents = APR_POLLOUT;
        pfd.desc.f    = ctx->proc->in;
        rc = apr_pollset_add(ctx->pollset, &pfd);
        ap_assert(rc == APR_SUCCESS);

        pfd.reqevents = APR_POLLIN;
        pfd.desc.f    = ctx->proc->out;
        rc = apr_pollset_add(ctx->pollset, &pfd);
        ap_assert(rc == APR_SUCCESS);
    }
#endif

    return APR_SUCCESS;
}

static const char *get_cfg_string(ef_dir_t *dc, ef_filter_t *filter, apr_pool_t *p)
{
    const char *debug_str = dc->debug == -1 ?
        "DebugLevel=0" : apr_psprintf(p, "DebugLevel=%d", dc->debug);
    const char *log_stderr_str = dc->log_stderr < 1 ?
        "NoLogStderr" : "LogStderr";
    const char *preserve_content_length_str = filter->preserves_content_length ?
        "PreservesContentLength" : "!PreserveContentLength";
    const char *intype_str = !filter->intype ?
        "*/*" : filter->intype;
    const char *outtype_str = !filter->outtype ?
        "(unchanged)" : filter->outtype;

    return apr_psprintf(p,
                        "ExtFilterOptions %s %s %s ExtFilterInType %s "
                        "ExtFilterOuttype %s",
                        debug_str, log_stderr_str, preserve_content_length_str,
                        intype_str, outtype_str);
}

static ef_filter_t *find_filter_def(const server_rec *s, const char *fname)
{
    ef_server_t *sc;
    ef_filter_t *f;

    sc = ap_get_module_config(s->module_config, &ext_filter_module);
    f = apr_hash_get(sc->h, fname, APR_HASH_KEY_STRING);
    if (!f && s != main_server) {
        s = main_server;
        sc = ap_get_module_config(s->module_config, &ext_filter_module);
        f = apr_hash_get(sc->h, fname, APR_HASH_KEY_STRING);
    }
    return f;
}

static apr_status_t init_filter_instance(ap_filter_t *f)
{
    ef_ctx_t *ctx;
    ef_dir_t *dc;
    apr_status_t rv;

    f->ctx = ctx = apr_pcalloc(f->r->pool, sizeof(ef_ctx_t));
    dc = ap_get_module_config(f->r->per_dir_config,
                              &ext_filter_module);
    ctx->dc = dc;
    /* look for the user-defined filter */
    ctx->filter = find_filter_def(f->r->server, f->frec->name);
    if (!ctx->filter) {
        ap_log_rerror(APLOG_MARK, APLOG_ERR, 0, f->r,
                      "couldn't find definition of filter '%s'",
                      f->frec->name);
        return APR_EINVAL;
    }
    ctx->p = f->r->pool;
    if (ctx->filter->intype &&
        ctx->filter->intype != INTYPE_ALL) {
        const char *ctypes;

        if (ctx->filter->mode == INPUT_FILTER) {
            ctypes = apr_table_get(f->r->headers_in, "Content-Type");
        }
        else {
            ctypes = f->r->content_type;
        }

        if (ctypes) {
            const char *ctype = ap_getword(f->r->pool, &ctypes, ';');

            if (strcasecmp(ctx->filter->intype, ctype)) {
                /* wrong IMT for us; don't mess with the output */
                ctx->noop = 1;
            }
        }
        else {
            ctx->noop = 1;
        }
    }
    if (ctx->filter->enable_env &&
        !apr_table_get(f->r->subprocess_env, ctx->filter->enable_env)) {
        /* an environment variable that enables the filter isn't set; bail */
        ctx->noop = 1;
    }
    if (ctx->filter->disable_env &&
        apr_table_get(f->r->subprocess_env, ctx->filter->disable_env)) {
        /* an environment variable that disables the filter is set; bail */
        ctx->noop = 1;
    }
    if (!ctx->noop) {
        rv = init_ext_filter_process(f);
        if (rv != APR_SUCCESS) {
            return rv;
        }
        if (ctx->filter->outtype &&
            ctx->filter->outtype != OUTTYPE_UNCHANGED) {
            ap_set_content_type(f->r, ctx->filter->outtype);
        }
        if (ctx->filter->preserves_content_length != 1) {
            /* nasty, but needed to avoid confusing the browser
             */
            apr_table_unset(f->r->headers_out, "Content-Length");
        }
    }

    if (dc->debug >= DBGLVL_SHOWOPTIONS) {
        ap_log_rerror(APLOG_MARK, APLOG_DEBUG, 0, f->r,
                      "%sfiltering `%s' of type `%s' through `%s', cfg %s",
                      ctx->noop ? "NOT " : "",
                      f->r->uri ? f->r->uri : f->r->filename,
                      f->r->content_type ? f->r->content_type : "(unspecified)",
                      ctx->filter->command,
                      get_cfg_string(dc, ctx->filter, f->r->pool));
    }

    return APR_SUCCESS;
}

/* drain_available_output():
 *
 * if any data is available from the filter, read it and append it
 * to the the bucket brigade
 */
static apr_status_t drain_available_output(ap_filter_t *f,
                                           apr_bucket_brigade *bb)
{
    request_rec *r = f->r;
    conn_rec *c = r->connection;
    ef_ctx_t *ctx = f->ctx;
    ef_dir_t *dc = ctx->dc;
    apr_size_t len;
    char buf[4096];
    apr_status_t rv;
    apr_bucket *b;

    while (1) {
        len = sizeof(buf);
        rv = apr_file_read(ctx->proc->out,
                      buf,
                      &len);
        if ((rv && !APR_STATUS_IS_EAGAIN(rv)) ||
            dc->debug >= DBGLVL_GORY) {
            ap_log_rerror(APLOG_MARK, APLOG_DEBUG, rv, r,
                          "apr_file_read(child output), len %" APR_SIZE_T_FMT,
                          !rv ? len : -1);
        }
        if (rv != APR_SUCCESS) {
            return rv;
        }
        b = apr_bucket_heap_create(buf, len, NULL, c->bucket_alloc);
        APR_BRIGADE_INSERT_TAIL(bb, b);
        return APR_SUCCESS;
    }
    /* we should never get here; if we do, a bogus error message would be
     * the least of our problems
     */
    return APR_ANONYMOUS;
}

static apr_status_t pass_data_to_filter(ap_filter_t *f, const char *data,
                                        apr_size_t len, apr_bucket_brigade *bb)
{
    ef_ctx_t *ctx = f->ctx;
    ef_dir_t *dc = ctx->dc;
    apr_status_t rv;
    apr_size_t bytes_written = 0;
    apr_size_t tmplen;

    do {
        tmplen = len - bytes_written;
        rv = apr_file_write(ctx->proc->in,
                       (const char *)data + bytes_written,
                       &tmplen);
        bytes_written += tmplen;
        if (rv != APR_SUCCESS && !APR_STATUS_IS_EAGAIN(rv)) {
            ap_log_rerror(APLOG_MARK, APLOG_ERR, rv, f->r,
                          "apr_file_write(child input), len %" APR_SIZE_T_FMT,
                          tmplen);
            return rv;
        }
        if (APR_STATUS_IS_EAGAIN(rv)) {
            /* XXX handle blocking conditions here...  if we block, we need
             * to read data from the child process and pass it down to the
             * next filter!
             */
            rv = drain_available_output(f, bb);
            if (APR_STATUS_IS_EAGAIN(rv)) {
#if APR_FILES_AS_SOCKETS
                int num_events;
                const apr_pollfd_t *pdesc;

                rv = apr_pollset_poll(ctx->pollset, f->r->server->timeout,
                                      &num_events, &pdesc);
                if (rv || dc->debug >= DBGLVL_GORY) {
                    ap_log_rerror(APLOG_MARK, APLOG_DEBUG,
                                  rv, f->r, "apr_pollset_poll()");
                }
                if (rv != APR_SUCCESS && !APR_STATUS_IS_EINTR(rv)) {
                    /* some error such as APR_TIMEUP */
                    return rv;
                }
#else /* APR_FILES_AS_SOCKETS */
                /* Yuck... I'd really like to wait until I can read
                 * or write, but instead I have to sleep and try again
                 */
                apr_sleep(100000); /* 100 milliseconds */
                if (dc->debug >= DBGLVL_GORY) {
                    ap_log_rerror(APLOG_MARK, APLOG_DEBUG,
                                  0, f->r, "apr_sleep()");
                }
#endif /* APR_FILES_AS_SOCKETS */
            }
            else if (rv != APR_SUCCESS) {
                return rv;
            }
        }
    } while (bytes_written < len);
    return rv;
}

/* ef_unified_filter:
 *
 * runs the bucket brigade bb through the filter and puts the result into
 * bb, dropping the previous content of bb (the input)
 */

static int ef_unified_filter(ap_filter_t *f, apr_bucket_brigade *bb)
{
    request_rec *r = f->r;
    conn_rec *c = r->connection;
    ef_ctx_t *ctx = f->ctx;
    apr_bucket *b;
    ef_dir_t *dc;
    apr_size_t len;
    const char *data;
    apr_status_t rv;
    char buf[4096];
    apr_bucket *eos = NULL;
    apr_bucket_brigade *bb_tmp;

    dc = ctx->dc;
    bb_tmp = apr_brigade_create(r->pool, c->bucket_alloc);

    for (b = APR_BRIGADE_FIRST(bb);
         b != APR_BRIGADE_SENTINEL(bb);
         b = APR_BUCKET_NEXT(b))
    {
        if (APR_BUCKET_IS_EOS(b)) {
            eos = b;
            break;
        }

        rv = apr_bucket_read(b, &data, &len, APR_BLOCK_READ);
        if (rv != APR_SUCCESS) {
            ap_log_rerror(APLOG_MARK, APLOG_ERR, rv, r, "apr_bucket_read()");
            return rv;
        }

        /* Good cast, we just tested len isn't negative */
        if (len > 0 &&
            (rv = pass_data_to_filter(f, data, (apr_size_t)len, bb_tmp))
                != APR_SUCCESS) {
            return rv;
        }
    }

    apr_brigade_cleanup(bb);
    APR_BRIGADE_CONCAT(bb, bb_tmp);
    apr_brigade_destroy(bb_tmp);

    if (eos) {
        /* close the child's stdin to signal that no more data is coming;
         * that will cause the child to finish generating output
         */
        if ((rv = apr_file_close(ctx->proc->in)) != APR_SUCCESS) {
            ap_log_rerror(APLOG_MARK, APLOG_ERR, rv, r,
                          "apr_file_close(child input)");
            return rv;
        }
        /* since we've seen eos and closed the child's stdin, set the proper pipe
         * timeout; we don't care if we don't return from apr_file_read() for a while...
         */
        rv = apr_file_pipe_timeout_set(ctx->proc->out,
                                       r->server->timeout);
        if (rv) {
            ap_log_rerror(APLOG_MARK, APLOG_ERR, rv, r,
                          "apr_file_pipe_timeout_set(child output)");
            return rv;
        }
    }

    do {
        len = sizeof(buf);
        rv = apr_file_read(ctx->proc->out,
                      buf,
                      &len);
        if ((rv && !APR_STATUS_IS_EOF(rv) && !APR_STATUS_IS_EAGAIN(rv)) ||
            dc->debug >= DBGLVL_GORY) {
            ap_log_rerror(APLOG_MARK, APLOG_DEBUG, rv, r,
                          "apr_file_read(child output), len %" APR_SIZE_T_FMT,
                          !rv ? len : -1);
        }
        if (APR_STATUS_IS_EAGAIN(rv)) {
            if (eos) {
                /* should not occur, because we have an APR timeout in place */
                AP_DEBUG_ASSERT(1 != 1);
            }
            return APR_SUCCESS;
        }

        if (rv == APR_SUCCESS) {
            b = apr_bucket_heap_create(buf, len, NULL, c->bucket_alloc);
            APR_BRIGADE_INSERT_TAIL(bb, b);
        }
    } while (rv == APR_SUCCESS);

    if (!APR_STATUS_IS_EOF(rv)) {
        return rv;
    }

    if (eos) {
        b = apr_bucket_eos_create(c->bucket_alloc);
        APR_BRIGADE_INSERT_TAIL(bb, b);
    }

    return APR_SUCCESS;
}

static apr_status_t ef_output_filter(ap_filter_t *f, apr_bucket_brigade *bb)
{
    request_rec *r = f->r;
    ef_ctx_t *ctx = f->ctx;
    apr_status_t rv;

    if (!ctx) {
        if ((rv = init_filter_instance(f)) != APR_SUCCESS) {
            ctx = f->ctx;
            ap_log_rerror(APLOG_MARK, APLOG_ERR, rv, r,
                          "can't initialise output filter %s: %s",
                          f->frec->name,
                          (ctx->dc->onfail == 1) ? "removing" : "aborting");
            ap_remove_output_filter(f);
            if (ctx->dc->onfail == 1) {
                return ap_pass_brigade(f->next, bb);
            }
            else {
                apr_bucket *e;
                f->r->status_line = "500 Internal Server Error";

                apr_brigade_cleanup(bb);
                e = ap_bucket_error_create(HTTP_INTERNAL_SERVER_ERROR,
                                           NULL, r->pool,
                                           f->c->bucket_alloc);
                APR_BRIGADE_INSERT_TAIL(bb, e);
                e = apr_bucket_eos_create(f->c->bucket_alloc);
                APR_BRIGADE_INSERT_TAIL(bb, e);
                ap_pass_brigade(f->next, bb);
                return AP_FILTER_ERROR;
            }
        }
        ctx = f->ctx;
    }
    if (ctx->noop) {
        ap_remove_output_filter(f);
        return ap_pass_brigade(f->next, bb);
    }

    rv = ef_unified_filter(f, bb);
    if (rv != APR_SUCCESS) {
        ap_log_rerror(APLOG_MARK, APLOG_ERR, rv, r,
                      "ef_unified_filter() failed");
    }

    if ((rv = ap_pass_brigade(f->next, bb)) != APR_SUCCESS) {
        ap_log_rerror(APLOG_MARK, APLOG_ERR, rv, r,
                      "ap_pass_brigade() failed");
    }
    return rv;
}

static int ef_input_filter(ap_filter_t *f, apr_bucket_brigade *bb,
                           ap_input_mode_t mode, apr_read_type_e block,
                           apr_off_t readbytes)
{
    ef_ctx_t *ctx = f->ctx;
    apr_status_t rv;

    if (!ctx) {
        if ((rv = init_filter_instance(f)) != APR_SUCCESS) {
            ctx = f->ctx;
            ap_log_rerror(APLOG_MARK, APLOG_ERR, rv, f->r,
                          "can't initialise input filter %s: %s",
                          f->frec->name,
                          (ctx->dc->onfail == 1) ? "removing" : "aborting");
            ap_remove_input_filter(f);
            if (ctx->dc->onfail == 1) {
                return ap_get_brigade(f->next, bb, mode, block, readbytes);
            }
            else {
                f->r->status = HTTP_INTERNAL_SERVER_ERROR;
                return HTTP_INTERNAL_SERVER_ERROR;
            }
        }
        ctx = f->ctx;
    }

    if (ctx->noop) {
        ap_remove_input_filter(f);
        return ap_get_brigade(f->next, bb, mode, block, readbytes);
    }

    rv = ap_get_brigade(f->next, bb, mode, block, readbytes);
    if (rv != APR_SUCCESS) {
        return rv;
    }

    rv = ef_unified_filter(f, bb);
    return rv;
}

module AP_MODULE_DECLARE_DATA ext_filter_module =
{
    STANDARD20_MODULE_STUFF,
    create_ef_dir_conf,
    merge_ef_dir_conf,
    create_ef_server_conf,
    NULL,
    cmds,
    register_hooks
};
