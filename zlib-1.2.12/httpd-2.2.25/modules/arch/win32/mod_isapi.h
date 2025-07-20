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

/**
 * @file mod_isapi.h
 * @brief ISAPI module extension to Apache
 *
 * @defgroup MOD_ISAPI mod_isapi
 * @ingroup  APACHE_MODS
 * @{
 */

#ifndef MOD_ISAPI_H
#define MOD_ISAPI_H

#ifdef __cplusplus
extern "C" {
#endif

/* The Version Information storage passed to a module on startup
 * via the GetExtensionVersion() entry point.
 */
typedef struct HSE_VERSION_INFO {
    apr_uint32_t dwExtensionVersion;
    char         lpszExtensionDesc[256];
} HSE_VERSION_INFO;

/* The startup entry point that must be exported by every ISAPI handler
 */
int APR_THREAD_FUNC GetExtensionVersion(HSE_VERSION_INFO *ver_info);
typedef int (APR_THREAD_FUNC *PFN_GETEXTENSIONVERSION)(HSE_VERSION_INFO *ver_info);

/* Our internal 'HCONN' representation, always opaque to the user.
 */
typedef struct isapi_cid isapi_cid;
typedef struct isapi_cid *HCONN;

/* Prototypes of the essential functions exposed by mod_isapi 
 * for the module to communicate with Apache.
 */
typedef int (APR_THREAD_FUNC 
                *PFN_GETSERVERVARIABLE)(HCONN         cid,
                                        char         *variable_name,
                                        void         *buf_data,
                                        apr_uint32_t *buf_size);
typedef int (APR_THREAD_FUNC 
                *PFN_WRITECLIENT)(HCONN         cid, 
                                  void         *buf_data,
                                  apr_uint32_t *buf_size,
                                  apr_uint32_t  flags);
typedef int (APR_THREAD_FUNC 
                *PFN_READCLIENT)(HCONN         cid, 
                                 void         *buf_data,
                                 apr_uint32_t *buf_size);
typedef int (APR_THREAD_FUNC 
                *PFN_SERVERSUPPORTFUNCTION)(HCONN         cid,
                                            apr_uint32_t  HSE_code,
                                            void         *buf_data,
                                            apr_uint32_t *buf_size,
                                            apr_uint32_t *flags);

/* The ecb structure is passed on each invocation of the module
 */
typedef struct EXTENSION_CONTROL_BLOCK {
    apr_uint32_t   cbSize;
    apr_uint32_t   dwVersion;
    HCONN          ConnID;
    apr_uint32_t   dwHttpStatusCode;
    char           lpszLogData[80];
    char          *lpszMethod;
    char          *lpszQueryString;
    char          *lpszPathInfo;
    char          *lpszPathTranslated;
    apr_uint32_t   cbTotalBytes;
    apr_uint32_t   cbAvailable;
    unsigned char *lpbData;
    char          *lpszContentType;

    PFN_GETSERVERVARIABLE     GetServerVariable;
    PFN_WRITECLIENT           WriteClient;
    PFN_READCLIENT            ReadClient;
    PFN_SERVERSUPPORTFUNCTION ServerSupportFunction;
} EXTENSION_CONTROL_BLOCK;

/* Status/Headers structure to pass to HSE_SEND_HEADER_EX, 
 * an MS extension to ServerSupportFunction
 */
typedef struct HSE_SEND_HEADER_EX_INFO {
    const char * pszStatus; /* HTTP status text, such as "200 OK" */
    const char * pszHeader; /* HTTP header lines text, such as
                             *   "Content-type: text/plain\r\n"
                             *   "Content-Language: en\r\n" 
                             * Note that (in spite of cchFoo lengths below)
                             * NULL characters will interfere in headers.
                             */
    apr_uint32_t cchStatus; /* length of pszStatus text */
    apr_uint32_t cchHeader; /* length of pszHeader text */
    int          fKeepConn; /* Ignored: used to set keep-alive status,
                             * but Apache follows the client's negotiated
                             * HTTP contract to decide.
                             */
} HSE_SEND_HEADER_EX_INFO;

/* Our only 'supported' MS extended flag bit for TransmitFile,
 * HSE_IO_SEND_HEADERS indicates that Status+Headers are present
 * in the pszStatusCode member of the HSE_TF_INFO structure.
 */
#define HSE_IO_SEND_HEADERS 8

/* The remaining flags are MS extended flag bits that bear little
 * relation to Apache; the rules that the Apache server obeys follow
 * its own design and HTTP protocol filter rules.
 *
 * We do not support async, however, we fake it.  If HSE_IO_SYNC is 
 * not passed, and a completion context was defined, we will invoke the
 * completion function immediately following the transfer, and then
 * return to the caller.  If HSE_IO_SYNC is passed, there is no call
 * neccessary to the completion context.
 */
#define HSE_IO_SYNC  1
#define HSE_IO_ASYNC 2
#define HSE_IO_DISCONNECT_AFTER_SEND 4
#define HSE_IO_NODELAY 4096

/* The Completion function prototype.  This callback may be fixed with 
 * the HSE_REQ_IO_COMPLETION ServerSupportFunction call, or overriden
 * for the HSE_REQ_TRANSMIT_FILE call.
 */
typedef void (APR_THREAD_FUNC *PFN_HSE_IO_COMPLETION)
                                  (EXTENSION_CONTROL_BLOCK *ecb,
                                   void                    *ctxt,
                                   apr_uint32_t             cbIO,
                                   apr_uint32_t             dwError);

/* TransmitFile structure to pass to HSE_REQ_TRANSMIT_FILE, an MS extension
 */
typedef struct HSE_TF_INFO {
    PFN_HSE_IO_COMPLETION pfnHseIO;      /* Overrides the default setting of
                                          * HSE_REQ_IO_COMPLETION if not NULL
                                          */
    void                 *pContext;
    apr_os_file_t         hFile;         /* HANDLE/fd to transmit */
    const char           *pszStatusCode; /* Ignored if HSE_IO_SEND_HEADERS is 
                                          * not set.  Includes HTTP status text
                                          * plus header text lines, such as
                                          *   "200 OK\r\n"
                                          *   "Content-type: text/plain\r\n"
                                          */
    apr_uint32_t          BytesToWrite;  /* 0 is write-all */
    apr_uint32_t          Offset;        /* File Offset */
    void                 *pHead;         /* Prefix with *pHead body text */
    apr_uint32_t          HeadLength;    /* Length of *pHead body text */
    void                 *pTail;         /* Prefix with *pTail body text */
    apr_uint32_t          TailLength;    /* Length of *pTail body text */
    apr_uint32_t          dwFlags;       /* bit flags described above */
} HSE_TF_INFO;

typedef struct HSE_URL_MAPEX_INFO {
    char         lpszPath[260];
    apr_uint32_t dwFlags;
    apr_uint32_t cchMatchingPath;
    apr_uint32_t cchMatchingURL;
    apr_uint32_t dwReserved1;
    apr_uint32_t dwReserved2;
} HSE_URL_MAPEX_INFO;

/* Original ISAPI ServerSupportFunction() HSE_code methods */
#define HSE_REQ_SEND_URL_REDIRECT_RESP   1
#define HSE_REQ_SEND_URL                 2
#define HSE_REQ_SEND_RESPONSE_HEADER     3
#define HSE_REQ_DONE_WITH_SESSION        4
    
/* MS Extented methods to ISAPI ServerSupportFunction() HSE_code */
#define HSE_REQ_MAP_URL_TO_PATH          1001 /* Emulated */
#define HSE_REQ_GET_SSPI_INFO            1002 /* Not Supported */
#define HSE_APPEND_LOG_PARAMETER         1003 /* Supported */
#define HSE_REQ_IO_COMPLETION            1005 /* Emulated */
#define HSE_REQ_TRANSMIT_FILE            1006 /* Async Emulated */
#define HSE_REQ_REFRESH_ISAPI_ACL        1007 /* Not Supported */
#define HSE_REQ_IS_KEEP_CONN             1008 /* Supported */
#define HSE_REQ_ASYNC_READ_CLIENT        1010 /* Emulated */
/*   Added with ISAPI 4.0 */
#define HSE_REQ_GET_IMPERSONATION_TOKEN  1011 /* Not Supported */
#define HSE_REQ_MAP_URL_TO_PATH_EX       1012 /* Emulated */
#define HSE_REQ_ABORTIVE_CLOSE           1014 /* Ignored */
/*   Added after ISAPI 4.0 in IIS 5.0 */
#define HSE_REQ_GET_CERT_INFO_EX         1015 /* Not Supported */
#define HSE_REQ_SEND_RESPONSE_HEADER_EX  1016 /* Supported (no nulls!) */
#define HSE_REQ_CLOSE_CONNECTION         1017 /* Ignored */
#define HSE_REQ_IS_CONNECTED             1018 /* Supported */
#define HSE_REQ_EXTENSION_TRIGGER        1020 /* Not Supported */

/* The request entry point that must be exported by every ISAPI handler 
 */
apr_uint32_t APR_THREAD_FUNC HttpExtensionProc(EXTENSION_CONTROL_BLOCK *ecb);
typedef apr_uint32_t (APR_THREAD_FUNC 
                        *PFN_HTTPEXTENSIONPROC)(EXTENSION_CONTROL_BLOCK *ecb);

/* Allowable return values from HttpExtensionProc (apparently 0 is also 
 * accepted by MS IIS, and we will respect it as Success.)
 * If the HttpExtensionProc returns HSE_STATUS_PENDING, we will create
 * a wait mutex and lock on it, until HSE_REQ_DONE_WITH_SESSION is called.
 */
#define HSE_STATUS_SUCCESS                1
#define HSE_STATUS_SUCCESS_AND_KEEP_CONN  2 /* 1 vs 2 Ignored, we choose */
#define HSE_STATUS_PENDING                3 /* Emulated (thread lock) */
#define HSE_STATUS_ERROR                  4

/* Anticipated error code for common faults within mod_isapi itself
 */
#ifndef ERROR_INSUFFICIENT_BUFFER
#define ERROR_INSUFFICIENT_BUFFER ENOBUFS
#endif
#ifndef ERROR_INVALID_INDEX
#define ERROR_INVALID_INDEX EINVAL
#endif
#ifndef ERROR_INVALID_PARAMETER
#define ERROR_INVALID_PARAMETER EINVAL
#endif
#ifndef ERROR_READ_FAULT
#define ERROR_READ_FAULT EIO
#endif
#ifndef ERROR_WRITE_FAULT
#define ERROR_WRITE_FAULT EIO
#endif
#ifndef ERROR_SUCCESS
#define ERROR_SUCCESS 0
#endif

/* Valid flags passed with TerminateExtension()
 */
#define HSE_TERM_MUST_UNLOAD      1
#define HSE_TERM_ADVISORY_UNLOAD  2

/* The shutdown entry point �ptionally exported by an ISAPI handler, passed
 * HSE_TERM_MUST_UNLOAD or HSE_TERM_ADVISORY_UNLOAD.  The module may return 
 * if passed HSE_TERM_ADVISORY_UNLOAD, and the module will remain loaded.
 * If the module returns 1 to HSE_TERM_ADVISORY_UNLOAD it is immediately 
 * unloaded.  If the module is passed HSE_TERM_MUST_UNLOAD, its return value 
 * is ignored.
 */
int APR_THREAD_FUNC TerminateExtension(apr_uint32_t flags);
typedef int (APR_THREAD_FUNC *PFN_TERMINATEEXTENSION)(apr_uint32_t flags);

/* Module may return 0 if passed HSE_TERM_ADVISORY_UNLOAD, and the module
 * will remain loaded, or 1 if it consents to being unloaded. If the module
 * is passed HSE_TERM_MUST_UNLOAD, it's return value is ignored.
 */
#define HSE_TERM_MUST_UNLOAD      1
#define HSE_TERM_ADVISORY_UNLOAD  2

#ifdef __cplusplus
}
#endif

#endif	/* !MOD_ISAPI_H */
/** @} */

