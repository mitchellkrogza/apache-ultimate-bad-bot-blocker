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
 * Info Module.  Display configuration information for the server and
 * all included modules.
 *
 * <Location /server-info>
 * SetHandler server-info
 * </Location>
 *
 * GET /server-info - Returns full configuration page for server and all modules
 * GET /server-info?server - Returns server configuration only
 * GET /server-info?module_name - Returns configuration for a single module
 * GET /server-info?list - Returns quick list of included modules
 * GET /server-info?config - Returns full configuration
 * GET /server-info?hooks - Returns a listing of the modules active for each hook
 *
 * Original Author:
 *   Rasmus Lerdorf <rasmus vex.net>, May 1996
 *
 * Modified By:
 *   Lou Langholtz <ldl usi.utah.edu>, July 1997
 *
 * Apache 2.0 Port:
 *   Ryan Morgan <rmorgan covalent.net>, August 2000
 *
 */


#include "apr.h"
#include "apr_strings.h"
#include "apr_lib.h"
#include "apr_version.h"
#include "apu_version.h"
#define APR_WANT_STRFUNC
#include "apr_want.h"

#define CORE_PRIVATE

#include "httpd.h"
#include "http_config.h"
#include "http_core.h"
#include "http_log.h"
#include "http_main.h"
#include "http_protocol.h"
#include "http_connection.h"
#include "http_request.h"
#include "util_script.h"
#include "ap_mpm.h"

typedef struct
{
    const char *name;           /* matching module name */
    const char *info;           /* additional info */
} info_entry;

typedef struct
{
    apr_array_header_t *more_info;
} info_svr_conf;

module AP_MODULE_DECLARE_DATA info_module;

static void *create_info_config(apr_pool_t * p, server_rec * s)
{
    info_svr_conf *conf =
        (info_svr_conf *) apr_pcalloc(p, sizeof(info_svr_conf));

    conf->more_info = apr_array_make(p, 20, sizeof(info_entry));
    return conf;
}

static void *merge_info_config(apr_pool_t * p, void *basev, void *overridesv)
{
    info_svr_conf *new =
        (info_svr_conf *) apr_pcalloc(p, sizeof(info_svr_conf));
    info_svr_conf *base = (info_svr_conf *) basev;
    info_svr_conf *overrides = (info_svr_conf *) overridesv;

    new->more_info =
        apr_array_append(p, overrides->more_info, base->more_info);
    return new;
}

static void put_int_flush_right(request_rec * r, int i, int field)
{
    if (field > 1 || i > 9)
        put_int_flush_right(r, i / 10, field - 1);
    if (i)
        ap_rputc('0' + i % 10, r);
    else
        ap_rputs("&nbsp;", r);
}

static void mod_info_indent(request_rec * r, int nest,
                            const char *thisfn, int linenum)
{
    int i;
    const char *prevfn =
        ap_get_module_config(r->request_config, &info_module);
    if (thisfn == NULL)
        thisfn = "*UNKNOWN*";
    if (prevfn == NULL || 0 != strcmp(prevfn, thisfn)) {
        thisfn = ap_escape_html(r->pool, thisfn);
        ap_rprintf(r, "<dd><tt><strong>In file: %s</strong></tt></dd>\n",
                   thisfn);
        ap_set_module_config(r->request_config, &info_module,
                             (void *) thisfn);
    }

    ap_rputs("<dd><tt>", r);
    put_int_flush_right(r, linenum > 0 ? linenum : 0, 4);
    ap_rputs(":&nbsp;", r);

    for (i = 1; i <= nest; ++i) {
        ap_rputs("&nbsp;&nbsp;", r);
    }
}

static void mod_info_show_cmd(request_rec * r, const ap_directive_t * dir,
                              int nest)
{
    mod_info_indent(r, nest, dir->filename, dir->line_num);
    ap_rprintf(r, "%s <i>%s</i></tt></dd>\n",
               ap_escape_html(r->pool, dir->directive),
               ap_escape_html(r->pool, dir->args));
}

static void mod_info_show_open(request_rec * r, const ap_directive_t * dir,
                               int nest)
{
    mod_info_indent(r, nest, dir->filename, dir->line_num);
    ap_rprintf(r, "%s %s</tt></dd>\n",
               ap_escape_html(r->pool, dir->directive),
               ap_escape_html(r->pool, dir->args));
}

static void mod_info_show_close(request_rec * r, const ap_directive_t * dir,
                                int nest)
{
    const char *dirname = dir->directive;
    mod_info_indent(r, nest, dir->filename, 0);
    if (*dirname == '<') {
        ap_rprintf(r, "&lt;/%s&gt;</tt></dd>",
                   ap_escape_html(r->pool, dirname + 1));
    }
    else {
        ap_rprintf(r, "/%s</tt></dd>", ap_escape_html(r->pool, dirname));
    }
}

static int mod_info_has_cmd(const command_rec * cmds, ap_directive_t * dir)
{
    const command_rec *cmd;
    if (cmds == NULL)
        return 1;
    for (cmd = cmds; cmd->name; ++cmd) {
        if (strcasecmp(cmd->name, dir->directive) == 0)
            return 1;
    }
    return 0;
}

static void mod_info_show_parents(request_rec * r, ap_directive_t * node,
                                  int from, int to)
{
    if (from < to)
        mod_info_show_parents(r, node->parent, from, to - 1);
    mod_info_show_open(r, node, to);
}

static int mod_info_module_cmds(request_rec * r, const command_rec * cmds,
                                ap_directive_t * node, int from, int level)
{
    int shown = from;
    ap_directive_t *dir;
    if (level == 0)
        ap_set_module_config(r->request_config, &info_module, NULL);
    for (dir = node; dir; dir = dir->next) {
        if (dir->first_child != NULL) {
            if (level < mod_info_module_cmds(r, cmds, dir->first_child,
                                             shown, level + 1)) {
                shown = level;
                mod_info_show_close(r, dir, level);
            }
        }
        else if (mod_info_has_cmd(cmds, dir)) {
            if (shown < level) {
                mod_info_show_parents(r, dir->parent, shown, level - 1);
                shown = level;
            }
            mod_info_show_cmd(r, dir, level);
        }
    }
    return shown;
}

typedef struct
{                               /*XXX: should get something from apr_hooks.h instead */
    void (*pFunc) (void);       /* just to get the right size */
    const char *szName;
    const char *const *aszPredecessors;
    const char *const *aszSuccessors;
    int nOrder;
} hook_struct_t;

/*
 * hook_get_t is a pointer to a function that takes void as an argument and
 * returns a pointer to an apr_array_header_t.  The nasty WIN32 ifdef
 * is required to account for the fact that the ap_hook* calls all use
 * STDCALL calling convention.
 */
typedef apr_array_header_t *(
#ifdef WIN32
                                __stdcall
#endif
                                * hook_get_t)      (void);

typedef struct
{
    const char *name;
    hook_get_t get;
} hook_lookup_t;

static hook_lookup_t startup_hooks[] = {
    {"Pre-Config", ap_hook_get_pre_config},
    {"Test Configuration", ap_hook_get_test_config},
    {"Post Configuration", ap_hook_get_post_config},
    {"Open Logs", ap_hook_get_open_logs},
    {"Child Init", ap_hook_get_child_init},
    {NULL},
};

static hook_lookup_t request_hooks[] = {
    {"Pre-Connection", ap_hook_get_pre_connection},
    {"Create Connection", ap_hook_get_create_connection},
    {"Process Connection", ap_hook_get_process_connection},
    {"Create Request", ap_hook_get_create_request},
    {"Post-Read Request", ap_hook_get_post_read_request},
    {"Header Parse", ap_hook_get_header_parser},
    {"HTTP Scheme", ap_hook_get_http_scheme},
    {"Default Port", ap_hook_get_default_port},
    {"Quick Handler", ap_hook_get_quick_handler},
    {"Translate Name", ap_hook_get_translate_name},
    {"Map to Storage", ap_hook_get_map_to_storage},
    {"Check Access", ap_hook_get_access_checker},
    {"Verify User ID", ap_hook_get_check_user_id},
    {"Verify User Access", ap_hook_get_auth_checker},
    {"Check Type", ap_hook_get_type_checker},
    {"Fixups", ap_hook_get_fixups},
    {"Insert Filters", ap_hook_get_insert_filter},
    {"Content Handlers", ap_hook_get_handler},
    {"Logging", ap_hook_get_log_transaction},
    {"Insert Errors", ap_hook_get_insert_error_filter},
    {NULL},
};

static int module_find_hook(module * modp, hook_get_t hook_get)
{
    int i;
    apr_array_header_t *hooks = hook_get();
    hook_struct_t *elts;

    if (!hooks) {
        return 0;
    }

    elts = (hook_struct_t *) hooks->elts;

    for (i = 0; i < hooks->nelts; i++) {
        if (strcmp(elts[i].szName, modp->name) == 0) {
            return 1;
        }
    }

    return 0;
}

static void module_participate(request_rec * r,
                               module * modp,
                               hook_lookup_t * lookup, int *comma)
{
    if (module_find_hook(modp, lookup->get)) {
        if (*comma) {
            ap_rputs(", ", r);
        }
        ap_rvputs(r, "<tt>", lookup->name, "</tt>", NULL);
        *comma = 1;
    }
}

static void module_request_hook_participate(request_rec * r, module * modp)
{
    int i, comma = 0;

    ap_rputs("<dt><strong>Request Phase Participation:</strong>\n", r);

    for (i = 0; request_hooks[i].name; i++) {
        module_participate(r, modp, &request_hooks[i], &comma);
    }

    if (!comma) {
        ap_rputs("<tt> <em>none</em></tt>", r);
    }
    ap_rputs("</dt>\n", r);
}

static const char *find_more_info(server_rec * s, const char *module_name)
{
    int i;
    info_svr_conf *conf =
        (info_svr_conf *) ap_get_module_config(s->module_config,
                                               &info_module);
    info_entry *entry = (info_entry *) conf->more_info->elts;

    if (!module_name) {
        return 0;
    }
    for (i = 0; i < conf->more_info->nelts; i++) {
        if (!strcmp(module_name, entry->name)) {
            return entry->info;
        }
        entry++;
    }
    return 0;
}

static int show_server_settings(request_rec * r)
{
    server_rec *serv = r->server;
    int max_daemons, forked, threaded;

    ap_rputs("<h2><a name=\"server\">Server Settings</a></h2>", r);
    ap_rprintf(r,
               "<dl><dt><strong>Server Version:</strong> "
               "<font size=\"+1\"><tt>%s</tt></font></dt>\n",
               ap_get_server_description());
    ap_rprintf(r,
               "<dt><strong>Server Built:</strong> "
               "<font size=\"+1\"><tt>%s</tt></font></dt>\n",
               ap_get_server_built());
    ap_rprintf(r,
               "<dt><strong>Server loaded APR Version:</strong> "
               "<tt>%s</tt></dt>\n", apr_version_string());
    ap_rprintf(r,
               "<dt><strong>Compiled with APR Version:</strong> "
               "<tt>%s</tt></dt>\n", APR_VERSION_STRING);
    ap_rprintf(r,
               "<dt><strong>Server loaded APU Version:</strong> "
               "<tt>%s</tt></dt>\n", apu_version_string());
    ap_rprintf(r,
               "<dt><strong>Compiled with APU Version:</strong> "
               "<tt>%s</tt></dt>\n", APU_VERSION_STRING);
    ap_rprintf(r,
               "<dt><strong>Module Magic Number:</strong> "
               "<tt>%d:%d</tt></dt>\n", MODULE_MAGIC_NUMBER_MAJOR,
               MODULE_MAGIC_NUMBER_MINOR);
    ap_rprintf(r,
               "<dt><strong>Hostname/port:</strong> "
               "<tt>%s:%u</tt></dt>\n",
               ap_escape_html(r->pool, ap_get_server_name(r)),
               ap_get_server_port(r));
    ap_rprintf(r,
               "<dt><strong>Timeouts:</strong> "
               "<tt>connection: %d &nbsp;&nbsp; "
               "keep-alive: %d</tt></dt>",
               (int) (apr_time_sec(serv->timeout)),
               (int) (apr_time_sec(serv->keep_alive_timeout)));
    ap_mpm_query(AP_MPMQ_MAX_DAEMON_USED, &max_daemons);
    ap_mpm_query(AP_MPMQ_IS_THREADED, &threaded);
    ap_mpm_query(AP_MPMQ_IS_FORKED, &forked);
    ap_rprintf(r, "<dt><strong>MPM Name:</strong> <tt>%s</tt></dt>\n",
               ap_show_mpm());
    ap_rprintf(r,
               "<dt><strong>MPM Information:</strong> "
               "<tt>Max Daemons: %d Threaded: %s Forked: %s</tt></dt>\n",
               max_daemons, threaded ? "yes" : "no", forked ? "yes" : "no");
    ap_rprintf(r,
               "<dt><strong>Server Architecture:</strong> "
               "<tt>%ld-bit</tt></dt>\n", 8 * (long) sizeof(void *));
    ap_rprintf(r,
               "<dt><strong>Server Root:</strong> "
               "<tt>%s</tt></dt>\n", ap_server_root);
    ap_rprintf(r,
               "<dt><strong>Config File:</strong> "
               "<tt>%s</tt></dt>\n", ap_conftree->filename);

    ap_rputs("<dt><strong>Server Built With:</strong>\n"
             "<tt style=\"white-space: pre;\">\n", r);

    /* TODO: Not all of these defines are getting set like they do in main.c.
     *       Missing some headers?
     */

#ifdef BIG_SECURITY_HOLE
    ap_rputs(" -D BIG_SECURITY_HOLE\n", r);
#endif

#ifdef SECURITY_HOLE_PASS_AUTHORIZATION
    ap_rputs(" -D SECURITY_HOLE_PASS_AUTHORIZATION\n", r);
#endif

#ifdef OS
    ap_rputs(" -D OS=\"" OS "\"\n", r);
#endif

#ifdef APACHE_MPM_DIR
    ap_rputs(" -D APACHE_MPM_DIR=\"" APACHE_MPM_DIR "\"\n", r);
#endif

#ifdef HAVE_SHMGET
    ap_rputs(" -D HAVE_SHMGET\n", r);
#endif

#if APR_FILE_BASED_SHM
    ap_rputs(" -D APR_FILE_BASED_SHM\n", r);
#endif

#if APR_HAS_SENDFILE
    ap_rputs(" -D APR_HAS_SENDFILE\n", r);
#endif

#if APR_HAS_MMAP
    ap_rputs(" -D APR_HAS_MMAP\n", r);
#endif

#ifdef NO_WRITEV
    ap_rputs(" -D NO_WRITEV\n", r);
#endif

#ifdef NO_LINGCLOSE
    ap_rputs(" -D NO_LINGCLOSE\n", r);
#endif

#if APR_HAVE_IPV6
    ap_rputs(" -D APR_HAVE_IPV6 (IPv4-mapped addresses ", r);
#ifdef AP_ENABLE_V4_MAPPED
    ap_rputs("enabled)\n", r);
#else
    ap_rputs("disabled)\n", r);
#endif
#endif

#if APR_USE_FLOCK_SERIALIZE
    ap_rputs(" -D APR_USE_FLOCK_SERIALIZE\n", r);
#endif

#if APR_USE_SYSVSEM_SERIALIZE
    ap_rputs(" -D APR_USE_SYSVSEM_SERIALIZE\n", r);
#endif

#if APR_USE_POSIXSEM_SERIALIZE
    ap_rputs(" -D APR_USE_POSIXSEM_SERIALIZE\n", r);
#endif

#if APR_USE_FCNTL_SERIALIZE
    ap_rputs(" -D APR_USE_FCNTL_SERIALIZE\n", r);
#endif

#if APR_USE_PROC_PTHREAD_SERIALIZE
    ap_rputs(" -D APR_USE_PROC_PTHREAD_SERIALIZE\n", r);
#endif
#if APR_PROCESS_LOCK_IS_GLOBAL
    ap_rputs(" -D APR_PROCESS_LOCK_IS_GLOBAL\n", r);
#endif

#ifdef SINGLE_LISTEN_UNSERIALIZED_ACCEPT
    ap_rputs(" -D SINGLE_LISTEN_UNSERIALIZED_ACCEPT\n", r);
#endif

#if APR_HAS_OTHER_CHILD
    ap_rputs(" -D APR_HAS_OTHER_CHILD\n", r);
#endif

#ifdef AP_HAVE_RELIABLE_PIPED_LOGS
    ap_rputs(" -D AP_HAVE_RELIABLE_PIPED_LOGS\n", r);
#endif

#ifdef BUFFERED_LOGS
    ap_rputs(" -D BUFFERED_LOGS\n", r);
#ifdef PIPE_BUF
    ap_rputs(" -D PIPE_BUF=%ld\n", (long) PIPE_BUF, r);
#endif
#endif

#if APR_CHARSET_EBCDIC
    ap_rputs(" -D APR_CHARSET_EBCDIC\n", r);
#endif

#ifdef NEED_HASHBANG_EMUL
    ap_rputs(" -D NEED_HASHBANG_EMUL\n", r);
#endif

#ifdef SHARED_CORE
    ap_rputs(" -D SHARED_CORE\n", r);
#endif

/* This list displays the compiled in default paths: */
#ifdef HTTPD_ROOT
    ap_rputs(" -D HTTPD_ROOT=\"" HTTPD_ROOT "\"\n", r);
#endif

#ifdef SUEXEC_BIN
    ap_rputs(" -D SUEXEC_BIN=\"" SUEXEC_BIN "\"\n", r);
#endif

#if defined(SHARED_CORE) && defined(SHARED_CORE_DIR)
    ap_rputs(" -D SHARED_CORE_DIR=\"" SHARED_CORE_DIR "\"\n", r);
#endif

#ifdef DEFAULT_PIDLOG
    ap_rputs(" -D DEFAULT_PIDLOG=\"" DEFAULT_PIDLOG "\"\n", r);
#endif

#ifdef DEFAULT_SCOREBOARD
    ap_rputs(" -D DEFAULT_SCOREBOARD=\"" DEFAULT_SCOREBOARD "\"\n", r);
#endif

#ifdef DEFAULT_LOCKFILE
    ap_rputs(" -D DEFAULT_LOCKFILE=\"" DEFAULT_LOCKFILE "\"\n", r);
#endif

#ifdef DEFAULT_ERRORLOG
    ap_rputs(" -D DEFAULT_ERRORLOG=\"" DEFAULT_ERRORLOG "\"\n", r);
#endif


#ifdef AP_TYPES_CONFIG_FILE
    ap_rputs(" -D AP_TYPES_CONFIG_FILE=\"" AP_TYPES_CONFIG_FILE "\"\n", r);
#endif

#ifdef SERVER_CONFIG_FILE
    ap_rputs(" -D SERVER_CONFIG_FILE=\"" SERVER_CONFIG_FILE "\"\n", r);
#endif
    ap_rputs("</tt></dt>\n", r);
    ap_rputs("</dl><hr />", r);
    return 0;
}

static int dump_a_hook(request_rec * r, hook_get_t hook_get)
{
    int i;
    char qs;
    hook_struct_t *elts;
    apr_array_header_t *hooks = hook_get();

    if (!hooks) {
        return 0;
    }

    if (r->args && strcasecmp(r->args, "hooks") == 0) {
        qs = '?';
    }
    else {
        qs = '#';
    }

    elts = (hook_struct_t *) hooks->elts;

    for (i = 0; i < hooks->nelts; i++) {
        ap_rprintf(r,
                   "&nbsp;&nbsp; %02d <a href=\"%c%s\">%s</a> <br/>",
                   elts[i].nOrder, qs, elts[i].szName, elts[i].szName);
    }
    return 0;
}

static int show_active_hooks(request_rec * r)
{
    int i;
    ap_rputs("<h2><a name=\"startup_hooks\">Startup Hooks</a></h2>\n<dl>", r);

    for (i = 0; startup_hooks[i].name; i++) {
        ap_rprintf(r, "<dt><strong>%s:</strong>\n <br /><tt>\n",
                   startup_hooks[i].name);
        dump_a_hook(r, startup_hooks[i].get);
        ap_rputs("\n  </tt>\n</dt>\n", r);
    }

    ap_rputs
        ("</dl>\n<hr />\n<h2><a name=\"request_hooks\">Request Hooks</a></h2>\n<dl>",
         r);

    for (i = 0; request_hooks[i].name; i++) {
        ap_rprintf(r, "<dt><strong>%s:</strong>\n <br /><tt>\n",
                   request_hooks[i].name);
        dump_a_hook(r, request_hooks[i].get);
        ap_rputs("\n  </tt>\n</dt>\n", r);
    }

    ap_rputs("</dl>\n<hr />\n", r);

    return 0;
}

static int display_info(request_rec * r)
{
    module *modp = NULL;
    server_rec *serv = r->server;
    const char *more_info;
    const command_rec *cmd = NULL;
    int comma = 0;

    if (strcmp(r->handler, "server-info"))
        return DECLINED;

    r->allowed |= (AP_METHOD_BIT << M_GET);
    if (r->method_number != M_GET)
        return DECLINED;

    ap_set_content_type(r, "text/html; charset=ISO-8859-1");

    ap_rputs(DOCTYPE_XHTML_1_0T
             "<html xmlns=\"http://www.w3.org/1999/xhtml\">\n"
             "<head>\n"
             "  <title>Server Information</title>\n" "</head>\n", r);
    ap_rputs("<body><h1 style=\"text-align: center\">"
             "Apache Server Information</h1>\n", r);
    if (!r->args || strcasecmp(r->args, "list")) {
        if (!r->args) {
            ap_rputs("<dl><dt><tt>Subpages:<br />", r);
            ap_rputs("<a href=\"?config\">Configuration Files</a>, "
                     "<a href=\"?server\">Server Settings</a>, "
                     "<a href=\"?list\">Module List</a>,  "
                     "<a href=\"?hooks\">Active Hooks</a>", r);
            ap_rputs("</tt></dt></dl><hr />", r);

            ap_rputs("<dl><dt><tt>Sections:<br />", r);
            ap_rputs("<a href=\"#server\">Server Settings</a>, "
                     "<a href=\"#startup_hooks\">Startup Hooks</a>, "
                     "<a href=\"#request_hooks\">Request Hooks</a>", r);
            ap_rputs("</tt></dt></dl><hr />", r);

            ap_rputs("<dl><dt><tt>Loaded Modules: <br />", r);
            /* TODO: Sort by Alpha */
            for (modp = ap_top_module; modp; modp = modp->next) {
                ap_rprintf(r, "<a href=\"#%s\">%s</a>", modp->name,
                           modp->name);
                if (modp->next) {
                    ap_rputs(", ", r);
                }
            }
            ap_rputs("</tt></dt></dl><hr />", r);
        }

        if (!r->args || !strcasecmp(r->args, "server")) {
            show_server_settings(r);
        }

        if (!r->args || !strcasecmp(r->args, "hooks")) {
            show_active_hooks(r);
        }

        if (r->args && 0 == strcasecmp(r->args, "config")) {
            ap_rputs("<dl><dt><strong>Configuration:</strong>\n", r);
            mod_info_module_cmds(r, NULL, ap_conftree, 0, 0);
            ap_rputs("</dl><hr />", r);
        }
        else {
            for (modp = ap_top_module; modp; modp = modp->next) {
                if (!r->args || !strcasecmp(modp->name, r->args)) {
                    ap_rprintf(r,
                               "<dl><dt><a name=\"%s\"><strong>Module Name:</strong></a> "
                               "<font size=\"+1\"><tt><a href=\"?%s\">%s</a></tt></font></dt>\n",
                               modp->name, modp->name, modp->name);
                    ap_rputs("<dt><strong>Content handlers:</strong> ", r);

                    if (module_find_hook(modp, ap_hook_get_handler)) {
                        ap_rputs("<tt> <em>yes</em></tt>", r);
                    }
                    else {
                        ap_rputs("<tt> <em>none</em></tt>", r);
                    }

                    ap_rputs("</dt>", r);
                    ap_rputs
                        ("<dt><strong>Configuration Phase Participation:</strong>\n",
                         r);
                    if (modp->create_dir_config) {
                        if (comma) {
                            ap_rputs(", ", r);
                        }
                        ap_rputs("<tt>Create Directory Config</tt>", r);
                        comma = 1;
                    }
                    if (modp->merge_dir_config) {
                        if (comma) {
                            ap_rputs(", ", r);
                        }
                        ap_rputs("<tt>Merge Directory Configs</tt>", r);
                        comma = 1;
                    }
                    if (modp->create_server_config) {
                        if (comma) {
                            ap_rputs(", ", r);
                        }
                        ap_rputs("<tt>Create Server Config</tt>", r);
                        comma = 1;
                    }
                    if (modp->merge_server_config) {
                        if (comma) {
                            ap_rputs(", ", r);
                        }
                        ap_rputs("<tt>Merge Server Configs</tt>", r);
                        comma = 1;
                    }
                    if (!comma)
                        ap_rputs("<tt> <em>none</em></tt>", r);
                    comma = 0;
                    ap_rputs("</dt>", r);

                    module_request_hook_participate(r, modp);

                    cmd = modp->cmds;
                    if (cmd) {
                        ap_rputs
                            ("<dt><strong>Module Directives:</strong></dt>",
                             r);
                        while (cmd) {
                            if (cmd->name) {
                                ap_rprintf(r, "<dd><tt>%s%s - <i>",
                                           ap_escape_html(r->pool, cmd->name),
                                           cmd->name[0] == '<' ? "&gt;" : "");
                                if (cmd->errmsg) {
                                    ap_rputs(ap_escape_html(r->pool, cmd->errmsg), r);
                                }
                                ap_rputs("</i></tt></dd>\n", r);
                            }
                            else {
                                break;
                            }
                            cmd++;
                        }
                        ap_rputs
                            ("<dt><strong>Current Configuration:</strong></dt>\n",
                             r);
                        mod_info_module_cmds(r, modp->cmds, ap_conftree, 0,
                                             0);
                    }
                    else {
                        ap_rputs
                            ("<dt><strong>Module Directives:</strong> <tt>none</tt></dt>",
                             r);
                    }
                    more_info = find_more_info(serv, modp->name);
                    if (more_info) {
                        ap_rputs
                            ("<dt><strong>Additional Information:</strong>\n</dt><dd>",
                             r);
                        ap_rputs(more_info, r);
                        ap_rputs("</dd>", r);
                    }
                    ap_rputs("</dl><hr />\n", r);
                    if (r->args) {
                        break;
                    }
                }
            }
            if (!modp && r->args && strcasecmp(r->args, "server")) {
                ap_rputs("<p><b>No such module</b></p>\n", r);
            }
        }
    }
    else {
        ap_rputs("<dl><dt>Server Module List</dt>", r);
        for (modp = ap_top_module; modp; modp = modp->next) {
            ap_rputs("<dd>", r);
            ap_rputs(modp->name, r);
            ap_rputs("</dd>", r);
        }
        ap_rputs("</dl><hr />", r);
    }
    ap_rputs(ap_psignature("", r), r);
    ap_rputs("</body></html>\n", r);
    /* Done, turn off timeout, close file and return */
    return 0;
}

static const char *add_module_info(cmd_parms * cmd, void *dummy,
                                   const char *name, const char *info)
{
    server_rec *s = cmd->server;
    info_svr_conf *conf =
        (info_svr_conf *) ap_get_module_config(s->module_config,
                                               &info_module);
    info_entry *new = apr_array_push(conf->more_info);

    new->name = name;
    new->info = info;
    return NULL;
}

static const command_rec info_cmds[] = {
    AP_INIT_TAKE2("AddModuleInfo", add_module_info, NULL, RSRC_CONF,
                  "a module name and additional information on that module"),
    {NULL}
};

static void register_hooks(apr_pool_t * p)
{
    ap_hook_handler(display_info, NULL, NULL, APR_HOOK_MIDDLE);
}

module AP_MODULE_DECLARE_DATA info_module = {
    STANDARD20_MODULE_STUFF,
    NULL,                       /* dir config creater */
    NULL,                       /* dir merger --- default is to override */
    create_info_config,         /* server config */
    merge_info_config,          /* merge server config */
    info_cmds,                  /* command apr_table_t */
    register_hooks
};
