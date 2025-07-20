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

#ifdef WIN32

#include "apr.h"
#include "arch/win32/apr_arch_file_io.h"
#include "arch/win32/apr_arch_misc.h"
#include "ap_regkey.h"

struct ap_regkey_t {
    apr_pool_t *pool;
    HKEY        hkey;
};


AP_DECLARE(const ap_regkey_t *) ap_regkey_const(int i)
{
    static struct ap_regkey_t ap_regkey_consts[7] =
    {
        {NULL, HKEY_CLASSES_ROOT},
        {NULL, HKEY_CURRENT_CONFIG},
        {NULL, HKEY_CURRENT_USER},
        {NULL, HKEY_LOCAL_MACHINE},
        {NULL, HKEY_USERS},
        {NULL, HKEY_PERFORMANCE_DATA},
        {NULL, HKEY_DYN_DATA}
    };
    return ap_regkey_consts + i;
}


static apr_status_t regkey_cleanup(void *key)
{
    ap_regkey_t *regkey = key;

    if (regkey->hkey && regkey->hkey != INVALID_HANDLE_VALUE) {
        RegCloseKey(regkey->hkey);
        regkey->hkey = INVALID_HANDLE_VALUE;
    }
    return APR_SUCCESS;
}


AP_DECLARE(apr_status_t) ap_regkey_open(ap_regkey_t **newkey,
                                        const ap_regkey_t *parentkey,
                                        const char *keyname,
                                        apr_int32_t flags,
                                        apr_pool_t *pool)
{
    DWORD access = KEY_QUERY_VALUE;
    DWORD exists;
    HKEY hkey;
    LONG rc;

    if (flags & APR_READ)
        access |= KEY_READ;
    if (flags & APR_WRITE)
        access |= KEY_WRITE;

#if APR_HAS_UNICODE_FS
    IF_WIN_OS_IS_UNICODE
    {
        apr_size_t keylen = strlen(keyname) + 1;
        apr_size_t wkeylen = 256;
        apr_wchar_t wkeyname[256];
        apr_status_t rv = apr_conv_utf8_to_ucs2(keyname, &keylen, wkeyname, &wkeylen);
        if (rv != APR_SUCCESS)
            return rv;
        else if (keylen)
            return APR_ENAMETOOLONG;

        if (flags & APR_CREATE)
            rc = RegCreateKeyExW(parentkey->hkey, wkeyname, 0, NULL, 0,
                                 access, NULL, &hkey, &exists);
        else
            rc = RegOpenKeyExW(parentkey->hkey, wkeyname, 0, access, &hkey);
    }
#endif /* APR_HAS_UNICODE_FS */
#if APR_HAS_ANSI_FS
    ELSE_WIN_OS_IS_ANSI
    {
        if (flags & APR_CREATE)
            rc = RegCreateKeyEx(parentkey->hkey, keyname, 0, NULL, 0,
                                access, NULL, &hkey, &exists);
        else
            rc = RegOpenKeyEx(parentkey->hkey, keyname, 0, access, &hkey);
    }
#endif
    if (rc != ERROR_SUCCESS) {
        return APR_FROM_OS_ERROR(rc);
    }
    if ((flags & APR_EXCL) && (exists == REG_OPENED_EXISTING_KEY)) {
        RegCloseKey(hkey);
        return APR_EEXIST;
    }

    *newkey = apr_palloc(pool, sizeof(**newkey));
    (*newkey)->pool = pool;
    (*newkey)->hkey = hkey;
    apr_pool_cleanup_register((*newkey)->pool, (void *)(*newkey),
                              regkey_cleanup, apr_pool_cleanup_null);
    return APR_SUCCESS;
}


AP_DECLARE(apr_status_t) ap_regkey_close(ap_regkey_t *regkey)
{
    apr_status_t stat;
    if ((stat = regkey_cleanup(regkey)) == APR_SUCCESS) {
        apr_pool_cleanup_kill(regkey->pool, regkey, regkey_cleanup);
    }
    return stat;
}


AP_DECLARE(apr_status_t) ap_regkey_remove(const ap_regkey_t *parent,
                                          const char *keyname,
                                          apr_pool_t *pool)
{
    LONG rc;

#if APR_HAS_UNICODE_FS
    IF_WIN_OS_IS_UNICODE
    {
        apr_size_t keylen = strlen(keyname) + 1;
        apr_size_t wkeylen = 256;
        apr_wchar_t wkeyname[256];
        apr_status_t rv = apr_conv_utf8_to_ucs2(keyname, &keylen, wkeyname, &wkeylen);
        if (rv != APR_SUCCESS)
            return rv;
        else if (keylen)
            return APR_ENAMETOOLONG;
        rc = RegDeleteKeyW(parent->hkey, wkeyname);
    }
#endif /* APR_HAS_UNICODE_FS */
#if APR_HAS_ANSI_FS
    ELSE_WIN_OS_IS_ANSI
    {
        /* We need to determine if subkeys exist on Win9x, to provide
         * consistent behavior with NT, which returns access denied
         * if subkeys exist when attempting to delete a key.
         */
        DWORD subkeys;
        HKEY hkey;
        rc = RegOpenKeyEx(parent->hkey, keyname, 0, KEY_READ, &hkey);
        if (rc != ERROR_SUCCESS)
            return APR_FROM_OS_ERROR(rc);
        rc = RegQueryInfoKey(hkey, NULL, NULL, NULL, &subkeys, NULL, NULL,
                             NULL, NULL, NULL, NULL, NULL);
        RegCloseKey(hkey);
        if (rc != ERROR_SUCCESS)
            return APR_FROM_OS_ERROR(rc);
        else if (subkeys)
            return APR_FROM_OS_ERROR(ERROR_ACCESS_DENIED);
        rc = RegDeleteKey(parent->hkey, keyname);
    }
#endif
    if (rc != ERROR_SUCCESS) {
        return APR_FROM_OS_ERROR(rc);
    }
    return APR_SUCCESS;
}


AP_DECLARE(apr_status_t) ap_regkey_value_get(char **result,
                                             ap_regkey_t *key,
                                             const char *valuename,
                                             apr_pool_t *pool)
{
    /* Retrieve a registry string value, and explode any envvars
     * that the system has configured (e.g. %SystemRoot%/someapp.exe)
     */
    LONG rc;
    DWORD type;
    apr_size_t size = 0;

#if APR_HAS_UNICODE_FS
    IF_WIN_OS_IS_UNICODE
    {
        apr_size_t valuelen = strlen(valuename) + 1;
        apr_size_t wvallen = 256;
        apr_wchar_t wvalname[256];
        apr_wchar_t *wvalue;
        apr_status_t rv;
        rv = apr_conv_utf8_to_ucs2(valuename, &valuelen, wvalname, &wvallen);
        if (rv != APR_SUCCESS)
            return rv;
        else if (valuelen)
            return APR_ENAMETOOLONG;
        /* Read to NULL buffer to determine value size */
        rc = RegQueryValueExW(key->hkey, wvalname, 0, &type, NULL, (DWORD *)&size);
        if (rc != ERROR_SUCCESS) {
            return APR_FROM_OS_ERROR(rc);
        }
        if ((size < 2) || (type != REG_SZ && type != REG_EXPAND_SZ)) {
            return APR_FROM_OS_ERROR(ERROR_INVALID_PARAMETER);
        }

        wvalue = apr_palloc(pool, size);
        /* Read value based on size query above */
        rc = RegQueryValueExW(key->hkey, wvalname, 0, &type,
                              (LPBYTE)wvalue, (DWORD *)&size);
        if (rc != ERROR_SUCCESS) {
            return APR_FROM_OS_ERROR(rc);
        }
        if (type == REG_EXPAND_SZ) {
            apr_wchar_t zbuf[1];
            size = ExpandEnvironmentStringsW(wvalue, zbuf, 0);
            if (size) {
                apr_wchar_t *tmp = wvalue;
                /* The size returned by ExpandEnvironmentStringsW is wchars */
                wvalue = apr_palloc(pool, size * 2);
                size = ExpandEnvironmentStringsW(tmp, wvalue, (DWORD)size);
            }
        }
        else {
            /* count wchars from RegQueryValueExW, rather than bytes */
            size /= 2;
        }
        /* ###: deliberately overallocate all but the trailing null.
         * We could precalculate the exact buffer here instead, the question
         * is a matter of storage v.s. cpu cycles.
         */
        valuelen = (size - 1) * 3 + 1;
        *result = apr_palloc(pool, valuelen);
        rv = apr_conv_ucs2_to_utf8(wvalue, &size, *result, &valuelen);
        if (rv != APR_SUCCESS)
            return rv;
        else if (size)
            return APR_ENAMETOOLONG;
    }
#endif /* APR_HAS_UNICODE_FS */
#if APR_HAS_ANSI_FS
    ELSE_WIN_OS_IS_ANSI
    {
        /* Read to NULL buffer to determine value size */
        rc = RegQueryValueEx(key->hkey, valuename, 0, &type, NULL, (DWORD *)&size);
        if (rc != ERROR_SUCCESS)
            return APR_FROM_OS_ERROR(rc);

        if ((size < 1) || (type != REG_SZ && type != REG_EXPAND_SZ)) {
            return APR_FROM_OS_ERROR(ERROR_INVALID_PARAMETER);
        }

        *result = apr_palloc(pool, size);
        /* Read value based on size query above */
        rc = RegQueryValueEx(key->hkey, valuename, 0, &type, *result, (DWORD *)&size);
        if (rc != ERROR_SUCCESS)
            return APR_FROM_OS_ERROR(rc);

        if (type == REG_EXPAND_SZ) {
            /* Advise ExpandEnvironmentStrings that we have a zero char
             * buffer to force computation of the required length.
             */
            char zbuf[1];
            size = ExpandEnvironmentStrings(*result, zbuf, 0);
            if (size) {
                char *tmp = *result;
                *result = apr_palloc(pool, size);
                size = ExpandEnvironmentStrings(tmp, *result, (DWORD)size);
            }
        }
    }
#endif
    return APR_SUCCESS;
}


AP_DECLARE(apr_status_t) ap_regkey_value_set(ap_regkey_t *key,
                                             const char *valuename,
                                             const char *value,
                                             apr_int32_t flags,
                                             apr_pool_t *pool)
{
    /* Retrieve a registry string value, and explode any envvars
     * that the system has configured (e.g. %SystemRoot%/someapp.exe)
     */
    LONG rc;
    apr_size_t size = strlen(value) + 1;
    DWORD type = (flags & AP_REGKEY_EXPAND) ? REG_EXPAND_SZ : REG_SZ;

#if APR_HAS_UNICODE_FS
    IF_WIN_OS_IS_UNICODE
    {
        apr_size_t alloclen;
        apr_size_t valuelen = strlen(valuename) + 1;
        apr_size_t wvallen = 256;
        apr_wchar_t wvalname[256];
        apr_wchar_t *wvalue;
        apr_status_t rv;
        rv = apr_conv_utf8_to_ucs2(valuename, &valuelen, wvalname, &wvallen);
        if (rv != APR_SUCCESS)
            return rv;
        else if (valuelen)
            return APR_ENAMETOOLONG;

        wvallen = alloclen = size;
        wvalue = apr_palloc(pool, alloclen * 2);
        rv = apr_conv_utf8_to_ucs2(value, &size, wvalue, &wvallen);
        if (rv != APR_SUCCESS)
            return rv;
        else if (size)
            return APR_ENAMETOOLONG;

        /* The size is the number of wchars consumed by apr_conv_utf8_to_ucs2
         * converted to bytes; the trailing L'\0' continues to be counted.
         */
        size = (alloclen - wvallen) * 2;
        rc = RegSetValueExW(key->hkey, wvalname, 0, type,
                            (LPBYTE)wvalue, (DWORD)size);
        if (rc != ERROR_SUCCESS)
            return APR_FROM_OS_ERROR(rc);
    }
#endif /* APR_HAS_UNICODE_FS */
#if APR_HAS_ANSI_FS
    ELSE_WIN_OS_IS_ANSI
    {
        rc = RegSetValueEx(key->hkey, valuename, 0, type, value, (DWORD)size);
        if (rc != ERROR_SUCCESS)
            return APR_FROM_OS_ERROR(rc);
    }
#endif
    return APR_SUCCESS;
}


AP_DECLARE(apr_status_t) ap_regkey_value_raw_get(void **result,
                                                 apr_size_t *resultsize,
                                                 apr_int32_t *resulttype,
                                                 ap_regkey_t *key,
                                                 const char *valuename,
                                                 apr_pool_t *pool)
{
    /* Retrieve a registry string value, and explode any envvars
     * that the system has configured (e.g. %SystemRoot%/someapp.exe)
     */
    LONG rc;

#if APR_HAS_UNICODE_FS
    IF_WIN_OS_IS_UNICODE
    {
        apr_size_t valuelen = strlen(valuename) + 1;
        apr_size_t wvallen = 256;
        apr_wchar_t wvalname[256];
        apr_status_t rv;
        rv = apr_conv_utf8_to_ucs2(valuename, &valuelen, wvalname, &wvallen);
        if (rv != APR_SUCCESS)
            return rv;
        else if (valuelen)
            return APR_ENAMETOOLONG;
        /* Read to NULL buffer to determine value size */
        rc = RegQueryValueExW(key->hkey, wvalname, 0, (LPDWORD)resulttype,
                              NULL, (LPDWORD)resultsize);
        if (rc != ERROR_SUCCESS) {
            return APR_FROM_OS_ERROR(rc);
        }

        /* Read value based on size query above */
        *result = apr_palloc(pool, *resultsize);
        rc = RegQueryValueExW(key->hkey, wvalname, 0, (LPDWORD)resulttype,
                             (LPBYTE)*result, (LPDWORD)resultsize);
    }
#endif /* APR_HAS_UNICODE_FS */
#if APR_HAS_ANSI_FS
    ELSE_WIN_OS_IS_ANSI
    {
        /* Read to NULL buffer to determine value size */
        rc = RegQueryValueEx(key->hkey, valuename, 0, (LPDWORD)resulttype,
                             NULL, (LPDWORD)resultsize);
        if (rc != ERROR_SUCCESS)
            return APR_FROM_OS_ERROR(rc);

        /* Read value based on size query above */
        *result = apr_palloc(pool, *resultsize);
        rc = RegQueryValueEx(key->hkey, valuename, 0, (LPDWORD)resulttype,
                             (LPBYTE)*result, (LPDWORD)resultsize);
        if (rc != ERROR_SUCCESS)
            return APR_FROM_OS_ERROR(rc);
    }
#endif
    if (rc != ERROR_SUCCESS) {
        return APR_FROM_OS_ERROR(rc);
    }

    return APR_SUCCESS;
}


AP_DECLARE(apr_status_t) ap_regkey_value_raw_set(ap_regkey_t *key,
                                                 const char *valuename,
                                                 const void *value,
                                                 apr_size_t valuesize,
                                                 apr_int32_t valuetype,
                                                 apr_pool_t *pool)
{
    LONG rc;

#if APR_HAS_UNICODE_FS
    IF_WIN_OS_IS_UNICODE
    {
        apr_size_t valuelen = strlen(valuename) + 1;
        apr_size_t wvallen = 256;
        apr_wchar_t wvalname[256];
        apr_status_t rv;
        rv = apr_conv_utf8_to_ucs2(valuename, &valuelen, wvalname, &wvallen);
        if (rv != APR_SUCCESS)
            return rv;
        else if (valuelen)
            return APR_ENAMETOOLONG;

        rc = RegSetValueExW(key->hkey, wvalname, 0, valuetype,
                            (LPBYTE)value, (DWORD)valuesize);
    }
#endif /* APR_HAS_UNICODE_FS */
#if APR_HAS_ANSI_FS
    ELSE_WIN_OS_IS_ANSI
    {
        rc = RegSetValueEx(key->hkey, valuename, 0, valuetype,
                            (LPBYTE)value, (DWORD)valuesize);
    }
#endif
    if (rc != ERROR_SUCCESS) {
        return APR_FROM_OS_ERROR(rc);
    }
    return APR_SUCCESS;
}


AP_DECLARE(apr_status_t) ap_regkey_value_array_get(apr_array_header_t **result,
                                                   ap_regkey_t *key,
                                                   const char *valuename,
                                                   apr_pool_t *pool)
{
    /* Retrieve a registry string value, and explode any envvars
     * that the system has configured (e.g. %SystemRoot%/someapp.exe)
     */
    apr_status_t rv;
    void *value;
    char *buf;
    char *tmp;
    apr_int32_t type;
    apr_size_t size = 0;

    rv = ap_regkey_value_raw_get(&value, &size, &type, key, valuename, pool);
    if (rv != APR_SUCCESS) {
        return rv;
    }
    else if (type != REG_MULTI_SZ) {
        return APR_EINVAL;
    }

#if APR_HAS_UNICODE_FS
    IF_WIN_OS_IS_UNICODE
    {
        apr_size_t alloclen;
        apr_size_t valuelen = strlen(valuename) + 1;

        /* ###: deliberately overallocate plus two extra nulls.
         * We could precalculate the exact buffer here instead, the question
         * is a matter of storage v.s. cpu cycles.
         */
        size /= 2;
        alloclen = valuelen = size * 3 + 2;
        buf = apr_palloc(pool, valuelen);
        rv = apr_conv_ucs2_to_utf8(value, &size, buf, &valuelen);
        if (rv != APR_SUCCESS)
            return rv;
        else if (size)
            return APR_ENAMETOOLONG;
        buf[(alloclen - valuelen)] = '\0';
        buf[(alloclen - valuelen) + 1] = '\0';
    }
#endif /* APR_HAS_UNICODE_FS */
#if APR_HAS_ANSI_FS
    ELSE_WIN_OS_IS_ANSI
    {
        /* Small possiblity the array is either unterminated
         * or single NULL terminated.  Avert.
         */
        buf = (char *)value;
        if (size < 2 || buf[size - 1] != '\0' || buf[size - 2] != '\0') {
            buf = apr_palloc(pool, size + 2);
            memcpy(buf, value, size);
            buf[size + 1] = '\0';
            buf[size] = '\0';
        }
    }
#endif

    size = 0;    /* Element Count */
    for (tmp = buf; *tmp; ++tmp) {
        ++size;
        while (*tmp) {
            ++tmp;
        }
    }

    *result = apr_array_make(pool, (int)size, sizeof(char *));
    for (tmp = buf; *tmp; ++tmp) {
        char **newelem = (char **) apr_array_push(*result);
        *newelem = tmp;
        while (*tmp) {
            ++tmp;
        }
    }

   return APR_SUCCESS;
}


AP_DECLARE(apr_status_t) ap_regkey_value_array_set(ap_regkey_t *key,
                                                   const char *valuename,
                                                   int nelts,
                                                   const char * const * elts,
                                                   apr_pool_t *pool)
{
    /* Retrieve a registry string value, and explode any envvars
     * that the system has configured (e.g. %SystemRoot%/someapp.exe)
     */
    int i;
    const void *value;
    apr_size_t bufsize;

#if APR_HAS_UNICODE_FS
    IF_WIN_OS_IS_UNICODE
    {
        apr_status_t rv;
        apr_wchar_t *buf;
        apr_wchar_t *tmp;
        apr_size_t bufrem;

        bufsize = 1; /* For trailing second null */
        for (i = 0; i < nelts; ++i) {
            bufsize += strlen(elts[i]) + 1;
        }
        if (!nelts) {
            ++bufsize;
        }

        bufrem = bufsize;
        buf = apr_palloc(pool, bufsize * 2);
        tmp = buf;
        for (i = 0; i < nelts; ++i) {
            apr_size_t eltsize = strlen(elts[i]) + 1;
            apr_size_t size = eltsize;
            rv = apr_conv_utf8_to_ucs2(elts[i], &size, tmp, &bufrem);
            if (rv != APR_SUCCESS)
                return rv;
            else if (size)
                return APR_ENAMETOOLONG;
            tmp += eltsize;
        }
        if (!nelts) {
            --bufrem;
            (*tmp++) = L'\0';
        }
        --bufrem;
        *tmp = L'\0'; /* Trailing second null */

        bufsize = (bufsize - bufrem) * 2;
        value = (void*)buf;
    }
#endif /* APR_HAS_UNICODE_FS */
#if APR_HAS_ANSI_FS
    ELSE_WIN_OS_IS_ANSI
    {
        char *buf;
        char *tmp;

        bufsize = 1; /* For trailing second null */
        for (i = 0; i < nelts; ++i) {
            bufsize += strlen(elts[i]) + 1;
        }
        if (!nelts) {
            ++bufsize;
        }
        buf = apr_palloc(pool, bufsize);
        tmp = buf;
        for (i = 0; i < nelts; ++i) {
            apr_size_t len = strlen(elts[i]) + 1;
            memcpy(tmp, elts[i], len);
            tmp += len;
        }
        if (!nelts) {
            (*tmp++) = '\0';
        }
        *tmp = '\0'; /* Trailing second null */
        value = buf;
    }
#endif
    return ap_regkey_value_raw_set(key, valuename, value,
                                   bufsize, REG_MULTI_SZ, pool);
}


AP_DECLARE(apr_status_t) ap_regkey_value_remove(const ap_regkey_t *key,
                                                const char *valuename,
                                                apr_pool_t *pool)
{
    LONG rc;

#if APR_HAS_UNICODE_FS
    IF_WIN_OS_IS_UNICODE
    {
        apr_size_t valuelen = strlen(valuename) + 1;
        apr_size_t wvallen = 256;
        apr_wchar_t wvalname[256];
        apr_status_t rv = apr_conv_utf8_to_ucs2(valuename, &valuelen, wvalname, &wvallen);
        if (rv != APR_SUCCESS)
            return rv;
        else if (valuelen)
            return APR_ENAMETOOLONG;
        rc = RegDeleteValueW(key->hkey, wvalname);
    }
#endif /* APR_HAS_UNICODE_FS */
#if APR_HAS_ANSI_FS
    ELSE_WIN_OS_IS_ANSI
    {
        rc = RegDeleteValue(key->hkey, valuename);
    }
#endif
    if (rc != ERROR_SUCCESS) {
        return APR_FROM_OS_ERROR(rc);
    }
    return APR_SUCCESS;
}

#endif /* defined WIN32 */
