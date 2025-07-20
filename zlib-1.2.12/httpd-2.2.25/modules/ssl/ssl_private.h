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

#ifndef SSL_PRIVATE_H
#define SSL_PRIVATE_H

/**
 * @file  ssl_private.h 
 * @brief Internal interfaces private to mod_ssl.
 *
 * @defgroup MOD_SSL_PRIVATE Private
 * @ingroup MOD_SSL
 * @{
 */

/** Apache headers */
#include "httpd.h"
#include "http_config.h"
#include "http_core.h"
#include "http_log.h"
#include "http_main.h"
#include "http_connection.h"
#include "http_request.h"
#include "http_protocol.h"
#include "http_vhost.h"
#include "util_script.h"
#include "util_filter.h"
#include "util_ebcdic.h"
#include "mpm.h"
#include "apr.h"
#include "apr_strings.h"
#define APR_WANT_STRFUNC
#include "apr_want.h"
#include "apr_tables.h"
#include "apr_lib.h"
#include "apr_fnmatch.h"
#include "apr_strings.h"
#include "apr_dbm.h"
#include "apr_rmm.h"
#include "apr_shm.h"
#include "apr_global_mutex.h"
#include "apr_optional.h"

#define MOD_SSL_VERSION AP_SERVER_BASEREVISION

/** mod_ssl headers */
#include "ssl_toolkit_compat.h"
#include "ssl_expr.h"

#ifdef SSL_OP_NO_TLSv1_2
#define HAVE_TLSV1_X
#endif

#if !defined(OPENSSL_NO_COMP) && !defined(SSL_OP_NO_COMPRESSION) \
    && OPENSSL_VERSION_NUMBER < 0x00908000L
#define OPENSSL_NO_COMP
#endif

#include "ssl_util_ssl.h"

/** The #ifdef macros are only defined AFTER including the above
 * therefore we cannot include these system files at the top  :-(
 */
#if APR_HAVE_SYS_TIME_H
#include <sys/time.h>
#endif
#if APR_HAVE_UNISTD_H
#include <unistd.h> /** needed for STDIN_FILENO et.al., at least on FreeBSD */
#endif

/**
 * Provide reasonable default for some defines
 */
#ifndef FALSE
#define FALSE (0)
#endif
#ifndef TRUE
#define TRUE (!FALSE)
#endif
#ifndef PFALSE
#define PFALSE ((void *)FALSE)
#endif
#ifndef PTRUE
#define PTRUE ((void *)TRUE)
#endif
#ifndef UNSET
#define UNSET (-1)
#endif
#ifndef NUL
#define NUL '\0'
#endif
#ifndef RAND_MAX
#include <limits.h>
#define RAND_MAX INT_MAX
#endif

/**
 * Provide reasonable defines for some types
 */
#ifndef BOOL
#define BOOL unsigned int
#endif
#ifndef UCHAR
#define UCHAR unsigned char
#endif

/**
 * Provide useful shorthands
 */
#define strEQ(s1,s2)     (strcmp(s1,s2)        == 0)
#define strNE(s1,s2)     (strcmp(s1,s2)        != 0)
#define strEQn(s1,s2,n)  (strncmp(s1,s2,n)     == 0)
#define strNEn(s1,s2,n)  (strncmp(s1,s2,n)     != 0)

#define strcEQ(s1,s2)    (strcasecmp(s1,s2)    == 0)
#define strcNE(s1,s2)    (strcasecmp(s1,s2)    != 0)
#define strcEQn(s1,s2,n) (strncasecmp(s1,s2,n) == 0)
#define strcNEn(s1,s2,n) (strncasecmp(s1,s2,n) != 0)

#define strIsEmpty(s)    (s == NULL || s[0] == NUL)

#define myConnConfig(c) \
(SSLConnRec *)ap_get_module_config(c->conn_config, &ssl_module)
#define myCtxConfig(sslconn, sc) (sslconn->is_proxy ? sc->proxy : sc->server)
#define myConnConfigSet(c, val) \
ap_set_module_config(c->conn_config, &ssl_module, val)
#define mySrvConfig(srv) (SSLSrvConfigRec *)ap_get_module_config(srv->module_config,  &ssl_module)
#define myDirConfig(req) (SSLDirConfigRec *)ap_get_module_config(req->per_dir_config, &ssl_module)
#define myModConfig(srv) (mySrvConfig((srv)))->mc
#define mySrvFromConn(c) (myConnConfig(c))->server
#define mySrvConfigFromConn(c) mySrvConfig(mySrvFromConn(c))
#define myModConfigFromConn(c) myModConfig(mySrvFromConn(c))

#define myCtxVarSet(mc,num,val)  mc->rCtx.pV##num = val
#define myCtxVarGet(mc,num,type) (type)(mc->rCtx.pV##num)

/**
 * Defaults for the configuration
 */
#ifndef SSL_SESSION_CACHE_TIMEOUT
#define SSL_SESSION_CACHE_TIMEOUT  300
#endif

/* Default setting for per-dir reneg buffer. */
#ifndef DEFAULT_RENEG_BUFFER_SIZE
#define DEFAULT_RENEG_BUFFER_SIZE (128 * 1024)
#endif

/**
 * Support for MM library
 */
#define SSL_MM_FILE_MODE ( APR_UREAD | APR_UWRITE | APR_GREAD | APR_WREAD )

/**
 * Support for DBM library
 */
#define SSL_DBM_FILE_MODE ( APR_UREAD | APR_UWRITE | APR_GREAD | APR_WREAD )

#if !defined(SSL_DBM_FILE_SUFFIX_DIR) && !defined(SSL_DBM_FILE_SUFFIX_PAG)
#if defined(DBM_SUFFIX)
#define SSL_DBM_FILE_SUFFIX_DIR DBM_SUFFIX
#define SSL_DBM_FILE_SUFFIX_PAG DBM_SUFFIX
#elif defined(__FreeBSD__) || (defined(DB_LOCK) && defined(DB_SHMEM))
#define SSL_DBM_FILE_SUFFIX_DIR ".db"
#define SSL_DBM_FILE_SUFFIX_PAG ".db"
#else
#define SSL_DBM_FILE_SUFFIX_DIR ".dir"
#define SSL_DBM_FILE_SUFFIX_PAG ".pag"
#endif
#endif

/**
 * Define the certificate algorithm types
 */

typedef int ssl_algo_t;

#define SSL_ALGO_UNKNOWN (0)
#define SSL_ALGO_RSA     (1<<0)
#define SSL_ALGO_DSA     (1<<1)
#define SSL_ALGO_ALL     (SSL_ALGO_RSA|SSL_ALGO_DSA)

#define SSL_AIDX_RSA     (0)
#define SSL_AIDX_DSA     (1)
#define SSL_AIDX_MAX     (2)


/**
 * Define IDs for the temporary RSA keys and DH params
 */

#define SSL_TMP_KEY_RSA_512  (0)
#define SSL_TMP_KEY_RSA_1024 (1)
#define SSL_TMP_KEY_DH_512   (2)
#define SSL_TMP_KEY_DH_1024  (3)
#define SSL_TMP_KEY_MAX      (4)

/**
 * Define the SSL options
 */
#define SSL_OPT_NONE           (0)
#define SSL_OPT_RELSET         (1<<0)
#define SSL_OPT_STDENVVARS     (1<<1)
#define SSL_OPT_EXPORTCERTDATA (1<<3)
#define SSL_OPT_FAKEBASICAUTH  (1<<4)
#define SSL_OPT_STRICTREQUIRE  (1<<5)
#define SSL_OPT_OPTRENEGOTIATE (1<<6)
#define SSL_OPT_ALL            (SSL_OPT_STDENVVARS|SSL_OPT_EXPORTCERTDATA|SSL_OPT_FAKEBASICAUTH|SSL_OPT_STRICTREQUIRE|SSL_OPT_OPTRENEGOTIATE)
typedef int ssl_opt_t;

/**
 * Define the SSL Protocol options
 */
#define SSL_PROTOCOL_NONE  (0)
#ifndef OPENSSL_NO_SSL2
#define SSL_PROTOCOL_SSLV2 (1<<0)
#endif
#define SSL_PROTOCOL_SSLV3 (1<<1)
#define SSL_PROTOCOL_TLSV1 (1<<2)
#ifdef OPENSSL_NO_SSL2
#define SSL_MOST_ALL SSL_PROTOCOL_SSLV3|SSL_PROTOCOL_TLSV1
#else
#define SSL_MOST_ALL SSL_PROTOCOL_SSLV2|SSL_PROTOCOL_SSLV3|SSL_PROTOCOL_TLSV1
#endif
#ifdef HAVE_TLSV1_X
#define SSL_PROTOCOL_TLSV1_1 (1<<3)
#define SSL_PROTOCOL_TLSV1_2 (1<<4)
#define SSL_PROTOCOL_ALL (SSL_MOST_ALL|SSL_PROTOCOL_TLSV1_1|SSL_PROTOCOL_TLSV1_2)
#else
#define SSL_PROTOCOL_ALL (SSL_MOST_ALL)
#endif
typedef int ssl_proto_t;

/**
 * Define the SSL verify levels
 */
typedef enum {
    SSL_CVERIFY_UNSET           = UNSET,
    SSL_CVERIFY_NONE            = 0,
    SSL_CVERIFY_OPTIONAL        = 1,
    SSL_CVERIFY_REQUIRE         = 2,
    SSL_CVERIFY_OPTIONAL_NO_CA  = 3
} ssl_verify_t;

#define SSL_VERIFY_PEER_STRICT \
     (SSL_VERIFY_PEER|SSL_VERIFY_FAIL_IF_NO_PEER_CERT)

#ifndef X509_V_ERR_CERT_UNTRUSTED
#define X509_V_ERR_CERT_UNTRUSTED 27
#endif

#define ssl_verify_error_is_optional(errnum) \
   ((errnum == X509_V_ERR_DEPTH_ZERO_SELF_SIGNED_CERT) \
    || (errnum == X509_V_ERR_SELF_SIGNED_CERT_IN_CHAIN) \
    || (errnum == X509_V_ERR_UNABLE_TO_GET_ISSUER_CERT_LOCALLY) \
    || (errnum == X509_V_ERR_CERT_UNTRUSTED) \
    || (errnum == X509_V_ERR_UNABLE_TO_VERIFY_LEAF_SIGNATURE))

/**
 * Define the SSL pass phrase dialog types
 */
typedef enum {
    SSL_PPTYPE_UNSET   = UNSET,
    SSL_PPTYPE_BUILTIN = 0,
    SSL_PPTYPE_FILTER  = 1,
	SSL_PPTYPE_PIPE    = 2
} ssl_pphrase_t;

/**
 * Define the Path Checking modes
 */
#define SSL_PCM_EXISTS     1
#define SSL_PCM_ISREG      2
#define SSL_PCM_ISDIR      4
#define SSL_PCM_ISNONZERO  8
typedef unsigned int ssl_pathcheck_t;

/**
 * Define the SSL session cache modes and structures
 */
typedef enum {
    SSL_SCMODE_UNSET = UNSET,
    SSL_SCMODE_NONE  = 0,
    SSL_SCMODE_DBM   = 1,
    SSL_SCMODE_SHMCB = 3,
    SSL_SCMODE_DC    = 4,
    SSL_SCMODE_NONE_NOT_NULL = 5
} ssl_scmode_t;

/**
 * Define the SSL mutex modes
 */
typedef enum {
    SSL_MUTEXMODE_UNSET  = UNSET,
    SSL_MUTEXMODE_NONE   = 0,
    SSL_MUTEXMODE_USED   = 1
} ssl_mutexmode_t;

/**
 * Define the SSL enabled state
 */
typedef enum {
    SSL_ENABLED_UNSET    = UNSET,
    SSL_ENABLED_FALSE    = 0,
    SSL_ENABLED_TRUE     = 1,
	SSL_ENABLED_OPTIONAL = 3
} ssl_enabled_t;

/**
 * Define the SSL requirement structure
 */
typedef struct {
    char     *cpExpr;
    ssl_expr *mpExpr;
} ssl_require_t;

/**
 * Define the SSL random number generator seeding source
 */
typedef enum {
    SSL_RSCTX_STARTUP = 1,
    SSL_RSCTX_CONNECT = 2
} ssl_rsctx_t;
typedef enum {
    SSL_RSSRC_BUILTIN = 1,
    SSL_RSSRC_FILE    = 2,
    SSL_RSSRC_EXEC    = 3,
    SSL_RSSRC_EGD     = 4
} ssl_rssrc_t;
typedef struct {
    ssl_rsctx_t  nCtx;
    ssl_rssrc_t  nSrc;
    char        *cpPath;
    int          nBytes;
} ssl_randseed_t;

/**
 * Define the structure of an ASN.1 anything
 */
typedef struct {
    long int       nData;
    unsigned char *cpData;
    apr_time_t     source_mtime;
} ssl_asn1_t;

/**
 * Define the mod_ssl per-module configuration structure
 * (i.e. the global configuration for each httpd process)
 */

typedef enum {
    SSL_SHUTDOWN_TYPE_UNSET,
    SSL_SHUTDOWN_TYPE_STANDARD,
    SSL_SHUTDOWN_TYPE_UNCLEAN,
    SSL_SHUTDOWN_TYPE_ACCURATE
} ssl_shutdown_type_e;

typedef struct {
    SSL *ssl;
    const char *client_dn;
    X509 *client_cert;
    ssl_shutdown_type_e shutdown_type;
    const char *verify_info;
    const char *verify_error;
    int verify_depth;
    int is_proxy;
    int disabled;
    enum {
        NON_SSL_OK = 0,        /* is SSL request, or error handling completed */
        NON_SSL_SEND_HDR_SEP,  /* Need to send the header separator */
        NON_SSL_SET_ERROR_MSG  /* Need to set the error message */
    } non_ssl_request;

    /* Track the handshake/renegotiation state for the connection so
     * that all client-initiated renegotiations can be rejected, as a
     * partial fix for CVE-2009-3555. */
    enum { 
        RENEG_INIT = 0, /* Before initial handshake */
        RENEG_REJECT, /* After initial handshake; any client-initiated
                       * renegotiation should be rejected */
        RENEG_ALLOW, /* A server-initated renegotiation is taking
                      * place (as dictated by configuration) */
        RENEG_ABORT /* Renegotiation initiated by client, abort the
                     * connection */
    } reneg_state;
    
    server_rec *server;
} SSLConnRec;

typedef struct {
    pid_t           pid;
    apr_pool_t     *pPool;
    BOOL            bFixed;
    int             nSessionCacheMode;
    char           *szSessionCacheDataFile;
    int             nSessionCacheDataSize;
    apr_shm_t      *pSessionCacheDataMM;
    apr_rmm_t      *pSessionCacheDataRMM;
    void           *tSessionCacheDataTable;
    ssl_mutexmode_t nMutexMode;
    apr_lockmech_e  nMutexMech;
    const char     *szMutexFile;
    apr_global_mutex_t   *pMutex;
    apr_array_header_t   *aRandSeed;
    apr_hash_t     *tVHostKeys;
    void           *pTmpKeys[SSL_TMP_KEY_MAX];
    apr_hash_t     *tPublicCert;
    apr_hash_t     *tPrivateKey;
#if defined(HAVE_OPENSSL_ENGINE_H) && defined(HAVE_ENGINE_INIT)
    const char     *szCryptoDevice;
#endif
    struct {
        void *pV1, *pV2, *pV3, *pV4, *pV5, *pV6, *pV7, *pV8, *pV9, *pV10;
    } rCtx;
} SSLModConfigRec;

/** public cert/private key */
typedef struct {
    /** 
     * server only has 1-2 certs/keys
     * 1 RSA and/or 1 DSA
     */
    const char  *cert_files[SSL_AIDX_MAX];
    const char  *key_files[SSL_AIDX_MAX];
    X509        *certs[SSL_AIDX_MAX];
    EVP_PKEY    *keys[SSL_AIDX_MAX];

    /** Certificates which specify the set of CA names which should be
     * sent in the CertificateRequest message: */
    const char  *ca_name_path;
    const char  *ca_name_file;
} modssl_pk_server_t;

typedef struct {
    /** proxy can have any number of cert/key pairs */
    const char  *cert_file;
    const char  *cert_path;
    const char  *ca_cert_file;
    STACK_OF(X509_INFO) *certs; /* Contains End Entity certs */
    STACK_OF(X509) **ca_certs; /* Contains ONLY chain certs for
                                * each item in certs.
                                * (ptr to array of ptrs) */
} modssl_pk_proxy_t;

/** stuff related to authentication that can also be per-dir */
typedef struct {
    /** known/trusted CAs */
    const char  *ca_cert_path;
    const char  *ca_cert_file;

    const char  *cipher_suite;

    /** for client or downstream server authentication */
    int          verify_depth;
    ssl_verify_t verify_mode;
} modssl_auth_ctx_t;

typedef struct SSLSrvConfigRec SSLSrvConfigRec;

typedef struct {
    SSLSrvConfigRec *sc; /** pointer back to server config */
    SSL_CTX *ssl_ctx;

    /** we are one or the other */
    modssl_pk_server_t *pks;
    modssl_pk_proxy_t  *pkp;

    ssl_proto_t  protocol;

    /** config for handling encrypted keys */
    ssl_pphrase_t pphrase_dialog_type;
    const char   *pphrase_dialog_path;

    const char  *cert_chain;

    /** certificate revocation list */
    const char  *crl_path;
    const char  *crl_file;
    X509_STORE  *crl;

    modssl_auth_ctx_t auth;
} modssl_ctx_t;

struct SSLSrvConfigRec {
    SSLModConfigRec *mc;
    ssl_enabled_t    enabled;
    BOOL             proxy_enabled;
    const char      *vhost_id;
    int              vhost_id_len;
    int              session_cache_timeout;
    BOOL             cipher_server_pref;
    BOOL             insecure_reneg;
    modssl_ctx_t    *server;
    modssl_ctx_t    *proxy;
    ssl_enabled_t    proxy_ssl_check_peer_expire;
    ssl_enabled_t    proxy_ssl_check_peer_cn;
#ifndef OPENSSL_NO_TLSEXT
    ssl_enabled_t    strict_sni_vhost_check;
#endif
#ifdef HAVE_FIPS
    BOOL             fips;
#endif
#ifndef OPENSSL_NO_COMP
    BOOL             compression;
#endif
};

/**
 * Define the mod_ssl per-directory configuration structure
 * (i.e. the local configuration for all <Directory>
 *  and .htaccess contexts)
 */
typedef struct {
    BOOL          bSSLRequired;
    apr_array_header_t *aRequirement;
    ssl_opt_t     nOptions;
    ssl_opt_t     nOptionsAdd;
    ssl_opt_t     nOptionsDel;
    const char   *szCipherSuite;
    ssl_verify_t  nVerifyClient;
    int           nVerifyDepth;
    const char   *szCACertificatePath;
    const char   *szCACertificateFile;
    const char   *szUserName;
    apr_size_t    nRenegBufferSize;
} SSLDirConfigRec;

/**
 *  function prototypes
 */

/**  API glue structures  */
extern module AP_MODULE_DECLARE_DATA ssl_module;

/** "global" stuff */
extern const char ssl_valid_ssl_mutex_string[];

/**  configuration handling   */
SSLModConfigRec *ssl_config_global_create(server_rec *);
void         ssl_config_global_fix(SSLModConfigRec *);
BOOL         ssl_config_global_isfixed(SSLModConfigRec *);
void        *ssl_config_server_create(apr_pool_t *, server_rec *);
void        *ssl_config_server_merge(apr_pool_t *, void *, void *);
void        *ssl_config_perdir_create(apr_pool_t *, char *);
void        *ssl_config_perdir_merge(apr_pool_t *, void *, void *);
const char  *ssl_cmd_SSLMutex(cmd_parms *, void *, const char *);
const char  *ssl_cmd_SSLPassPhraseDialog(cmd_parms *, void *, const char *);
const char  *ssl_cmd_SSLCryptoDevice(cmd_parms *, void *, const char *);
const char  *ssl_cmd_SSLRandomSeed(cmd_parms *, void *, const char *, const char *, const char *);
const char  *ssl_cmd_SSLEngine(cmd_parms *, void *, const char *);
const char  *ssl_cmd_SSLCipherSuite(cmd_parms *, void *, const char *);
const char  *ssl_cmd_SSLCertificateFile(cmd_parms *, void *, const char *);
const char  *ssl_cmd_SSLCertificateKeyFile(cmd_parms *, void *, const char *);
const char  *ssl_cmd_SSLCertificateChainFile(cmd_parms *, void *, const char *);
const char  *ssl_cmd_SSLCACertificatePath(cmd_parms *, void *, const char *);
const char  *ssl_cmd_SSLCACertificateFile(cmd_parms *, void *, const char *);
const char  *ssl_cmd_SSLCADNRequestPath(cmd_parms *, void *, const char *);
const char  *ssl_cmd_SSLCADNRequestFile(cmd_parms *, void *, const char *);
const char  *ssl_cmd_SSLCARevocationPath(cmd_parms *, void *, const char *);
const char  *ssl_cmd_SSLCARevocationFile(cmd_parms *, void *, const char *);
const char  *ssl_cmd_SSLHonorCipherOrder(cmd_parms *cmd, void *dcfg, int flag);
const char  *ssl_cmd_SSLCompression(cmd_parms *, void *, int flag);
const char  *ssl_cmd_SSLVerifyClient(cmd_parms *, void *, const char *);
const char  *ssl_cmd_SSLVerifyDepth(cmd_parms *, void *, const char *);
const char  *ssl_cmd_SSLSessionCache(cmd_parms *, void *, const char *);
const char  *ssl_cmd_SSLSessionCacheTimeout(cmd_parms *, void *, const char *);
const char  *ssl_cmd_SSLProtocol(cmd_parms *, void *, const char *);
const char  *ssl_cmd_SSLOptions(cmd_parms *, void *, const char *);
const char  *ssl_cmd_SSLRequireSSL(cmd_parms *, void *);
const char  *ssl_cmd_SSLRequire(cmd_parms *, void *, const char *);
const char  *ssl_cmd_SSLUserName(cmd_parms *, void *, const char *);
const char  *ssl_cmd_SSLRenegBufferSize(cmd_parms *cmd, void *dcfg, const char *arg);
const char  *ssl_cmd_SSLStrictSNIVHostCheck(cmd_parms *cmd, void *dcfg, int flag);
const char *ssl_cmd_SSLInsecureRenegotiation(cmd_parms *cmd, void *dcfg, int flag);

const char  *ssl_cmd_SSLProxyEngine(cmd_parms *cmd, void *dcfg, int flag);
const char  *ssl_cmd_SSLProxyProtocol(cmd_parms *, void *, const char *);
const char  *ssl_cmd_SSLProxyCipherSuite(cmd_parms *, void *, const char *);
const char  *ssl_cmd_SSLProxyVerify(cmd_parms *, void *, const char *);
const char  *ssl_cmd_SSLProxyVerifyDepth(cmd_parms *, void *, const char *);
const char  *ssl_cmd_SSLProxyCACertificatePath(cmd_parms *, void *, const char *);
const char  *ssl_cmd_SSLProxyCACertificateFile(cmd_parms *, void *, const char *);
const char  *ssl_cmd_SSLProxyCARevocationPath(cmd_parms *, void *, const char *);
const char  *ssl_cmd_SSLProxyCARevocationFile(cmd_parms *, void *, const char *);
const char  *ssl_cmd_SSLProxyMachineCertificatePath(cmd_parms *, void *, const char *);
const char  *ssl_cmd_SSLProxyMachineCertificateFile(cmd_parms *, void *, const char *);
const char  *ssl_cmd_SSLProxyMachineCertificateChainFile(cmd_parms *, void *, const char *);
const char  *ssl_cmd_SSLProxyCheckPeerExpire(cmd_parms *cmd, void *dcfg, int flag);
const char  *ssl_cmd_SSLProxyCheckPeerCN(cmd_parms *cmd, void *dcfg, int flag);

const char *ssl_cmd_SSLFIPS(cmd_parms *cmd, void *dcfg, int flag);

/**  module initialization  */
int          ssl_init_Module(apr_pool_t *, apr_pool_t *, apr_pool_t *, server_rec *);
void         ssl_init_Engine(server_rec *, apr_pool_t *);
void         ssl_init_ConfigureServer(server_rec *, apr_pool_t *, apr_pool_t *, SSLSrvConfigRec *);
void         ssl_init_CheckServers(server_rec *, apr_pool_t *);
STACK_OF(X509_NAME) 
            *ssl_init_FindCAList(server_rec *, apr_pool_t *, const char *, const char *);
void         ssl_init_Child(apr_pool_t *, server_rec *);
apr_status_t ssl_init_ModuleKill(void *data);

/**  Apache API hooks  */
int          ssl_hook_Auth(request_rec *);
int          ssl_hook_UserCheck(request_rec *);
int          ssl_hook_Access(request_rec *);
int          ssl_hook_Fixup(request_rec *);
int          ssl_hook_ReadReq(request_rec *);
int          ssl_hook_Upgrade(request_rec *);
void         ssl_hook_ConfigTest(apr_pool_t *pconf, server_rec *s);

/**  OpenSSL callbacks */
RSA         *ssl_callback_TmpRSA(SSL *, int, int);
DH          *ssl_callback_TmpDH(SSL *, int, int);
int          ssl_callback_SSLVerify(int, X509_STORE_CTX *);
int          ssl_callback_SSLVerify_CRL(int, X509_STORE_CTX *, conn_rec *);
int          ssl_callback_proxy_cert(SSL *ssl, MODSSL_CLIENT_CERT_CB_ARG_TYPE **x509, EVP_PKEY **pkey);
int          ssl_callback_NewSessionCacheEntry(SSL *, SSL_SESSION *);
SSL_SESSION *ssl_callback_GetSessionCacheEntry(SSL *, unsigned char *, int, int *);
void         ssl_callback_DelSessionCacheEntry(SSL_CTX *, SSL_SESSION *);
void         ssl_callback_Info(MODSSL_INFO_CB_ARG_TYPE, int, int);
#ifndef OPENSSL_NO_TLSEXT
int          ssl_callback_ServerNameIndication(SSL *, int *, modssl_ctx_t *);
#endif

/**  Session Cache Support  */
void         ssl_scache_init(server_rec *, apr_pool_t *);
void         ssl_scache_status_register(apr_pool_t *p);
void         ssl_scache_kill(server_rec *);
BOOL         ssl_scache_store(server_rec *, UCHAR *, int, time_t, SSL_SESSION *);
SSL_SESSION *ssl_scache_retrieve(server_rec *, UCHAR *, int);
void         ssl_scache_remove(server_rec *, UCHAR *, int);

char        *ssl_scache_id2sz(UCHAR *, int);
void         ssl_scache_dbm_init(server_rec *, apr_pool_t *);
void         ssl_scache_dbm_kill(server_rec *);
BOOL         ssl_scache_dbm_store(server_rec *, UCHAR *, int, time_t, SSL_SESSION *);
SSL_SESSION *ssl_scache_dbm_retrieve(server_rec *, UCHAR *, int);
void         ssl_scache_dbm_remove(server_rec *, UCHAR *, int);
void         ssl_scache_dbm_status(request_rec *r, int flags, apr_pool_t *pool);

void         ssl_scache_shmcb_init(server_rec *, apr_pool_t *);
void         ssl_scache_shmcb_kill(server_rec *);
BOOL         ssl_scache_shmcb_store(server_rec *, UCHAR *, int, time_t, SSL_SESSION *);
SSL_SESSION *ssl_scache_shmcb_retrieve(server_rec *, UCHAR *, int);
void         ssl_scache_shmcb_remove(server_rec *, UCHAR *, int);
void         ssl_scache_shmcb_status(request_rec *r, int flags, apr_pool_t *pool);

void         ssl_scache_dc_init(server_rec *, apr_pool_t *);
void         ssl_scache_dc_kill(server_rec *);
BOOL         ssl_scache_dc_store(server_rec *, UCHAR *, int, time_t, SSL_SESSION *);
SSL_SESSION *ssl_scache_dc_retrieve(server_rec *, UCHAR *, int);
void         ssl_scache_dc_remove(server_rec *, UCHAR *, int);
void         ssl_scache_dc_status(request_rec *r, int flags, apr_pool_t *pool);

/** Proxy Support */
int ssl_proxy_enable(conn_rec *c);
int ssl_engine_disable(conn_rec *c);

/**  I/O  */
void         ssl_io_filter_init(conn_rec *, SSL *);
void         ssl_io_filter_register(apr_pool_t *);
long         ssl_io_data_cb(BIO *, int, MODSSL_BIO_CB_ARG_TYPE *, int, long, long);

/* ssl_io_buffer_fill fills the setaside buffering of the HTTP request
 * to allow an SSL renegotiation to take place. */
int          ssl_io_buffer_fill(request_rec *r, apr_size_t maxlen);

/*  PRNG  */
int          ssl_rand_seed(server_rec *, apr_pool_t *, ssl_rsctx_t, char *);

/**  Utility Functions  */
char        *ssl_util_vhostid(apr_pool_t *, server_rec *);
apr_file_t  *ssl_util_ppopen(server_rec *, apr_pool_t *, const char *,
                             const char * const *);
void         ssl_util_ppclose(server_rec *, apr_pool_t *, apr_file_t *);
char        *ssl_util_readfilter(server_rec *, apr_pool_t *, const char *,
                                 const char * const *);
BOOL         ssl_util_path_check(ssl_pathcheck_t, const char *, apr_pool_t *);
ssl_algo_t   ssl_util_algotypeof(X509 *, EVP_PKEY *); 
char        *ssl_util_algotypestr(ssl_algo_t);
void         ssl_util_thread_setup(apr_pool_t *);
int          ssl_init_ssl_connection(conn_rec *c);

/**  Pass Phrase Support  */
void         ssl_pphrase_Handle(server_rec *, apr_pool_t *);

/**  Diffie-Hellman Parameter Support  */
DH           *ssl_dh_GetTmpParam(int);
DH           *ssl_dh_GetParamFromFile(char *);

unsigned char *ssl_asn1_table_set(apr_hash_t *table,
                                  const char *key,
                                  long int length);

ssl_asn1_t *ssl_asn1_table_get(apr_hash_t *table,
                               const char *key);

void ssl_asn1_table_unset(apr_hash_t *table,
                          const char *key);

const char *ssl_asn1_keystr(int keytype);

const char *ssl_asn1_table_keyfmt(apr_pool_t *p,
                                  const char *id,
                                  int keytype);
/**  Mutex Support  */
int          ssl_mutex_init(server_rec *, apr_pool_t *);
int          ssl_mutex_reinit(server_rec *, apr_pool_t *);
int          ssl_mutex_on(server_rec *);
int          ssl_mutex_off(server_rec *);

/**  Logfile Support  */
void         ssl_die(void);
void         ssl_log_ssl_error(const char *, int, int, server_rec *);

/**  Variables  */

/* Register variables for the lifetime of the process pool 'p'. */
void         ssl_var_register(apr_pool_t *p);
char        *ssl_var_lookup(apr_pool_t *, server_rec *, conn_rec *, request_rec *, char *);
const char  *ssl_ext_lookup(apr_pool_t *p, conn_rec *c, int peer, const char *oid);

extern apr_array_header_t *ssl_extlist_by_oid(request_rec *r, const char *oidstr);

void         ssl_var_log_config_register(apr_pool_t *p);

/* Extract SSL_*_DN_* variables into table 't' from SSL object 'ssl',
 * allocating from 'p': */
void modssl_var_extract_dns(apr_table_t *t, SSL *ssl, apr_pool_t *p);

#define APR_SHM_MAXSIZE (64 * 1024 * 1024)

#endif /* SSL_PRIVATE_H */
/** @} */

