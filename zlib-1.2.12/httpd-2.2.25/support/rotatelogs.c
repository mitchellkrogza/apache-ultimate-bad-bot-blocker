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
 * Simple program to rotate Apache logs without having to kill the server.
 *
 * Contributed by Ben Laurie <ben algroup.co.uk>
 *
 * 12 Mar 1996
 *
 * Ported to APR by Mladen Turk <mturk mappingsoft.com>
 *
 * 23 Sep 2001
 *
 * -l option added 2004-06-11
 *
 * -l causes the use of local time rather than GMT as the base for the
 * interval.  NB: Using -l in an environment which changes the GMT offset
 * (such as for BST or DST) can lead to unpredictable results!
 *
 * -f option added Feb, 2008. This causes rotatelog to open/create
 *    the logfile as soon as it's started, not as soon as it sees
 *    data.
 */


#include "apr.h"
#include "apr_lib.h"
#include "apr_strings.h"
#include "apr_errno.h"
#include "apr_file_io.h"
#include "apr_file_info.h"
#include "apr_general.h"
#include "apr_time.h"
#include "apr_getopt.h"

#if APR_HAVE_STDLIB_H
#include <stdlib.h>
#endif
#if APR_HAVE_STRING_H
#include <string.h>
#endif
#if APR_HAVE_STRINGS_H
#include <strings.h>
#endif

#define BUFSIZE         65536
#define ERRMSGSZ        256

#ifndef MAX_PATH
#define MAX_PATH        1024
#endif

static void usage(const char *argv0, const char *reason)
{
    if (reason) {
        fprintf(stderr, "%s\n", reason);
    }
    fprintf(stderr,
            "Usage: %s [-l] [-f] <logfile> "
            "{<rotation time in seconds>|<rotation size in megabytes>} "
            "[offset minutes from UTC]\n\n",
            argv0);
#ifdef OS2
    fprintf(stderr,
            "Add this:\n\nTransferLog \"|%s.exe /some/where 86400\"\n\n",
            argv0);
#else
    fprintf(stderr,
            "Add this:\n\nTransferLog \"|%s /some/where 86400\"\n\n",
            argv0);
    fprintf(stderr,
            "or \n\nTransferLog \"|%s /some/where 5M\"\n\n", argv0);
#endif
    fprintf(stderr,
            "to httpd.conf. The generated name will be /some/where.nnnn "
            "where nnnn is the\nsystem time at which the log nominally "
            "starts (N.B. if using a rotation time,\nthe time will always "
            "be a multiple of the rotation time, so you can synchronize\n"
            "cron scripts with it). At the end of each rotation time or "
            "when the file size\nis reached a new log is started.\n");
    exit(1);
}

static int get_now(int use_localtime, int utc_offset)
{
    apr_time_t tNow = apr_time_now();
    if (use_localtime) {
        /* Check for our UTC offset before using it, since it might
         * change if there's a switch between standard and daylight
         * savings time.
         */
        apr_time_exp_t lt;
        apr_time_exp_lt(&lt, tNow);
        utc_offset = lt.tm_gmtoff;
    }
    return (int)apr_time_sec(tNow) + utc_offset;
}

int main (int argc, const char * const argv[])
{
    char buf[BUFSIZE], buf2[MAX_PATH], errbuf[ERRMSGSZ];
    int tLogEnd = 0, tRotation = 0, utc_offset = 0;
    unsigned int sRotation = 0;
    int nMessCount = 0;
    apr_size_t nRead, nWrite;
    int use_strftime = 0;
    int use_localtime = 0;
    int bypass_io = 0;
    int now = 0;
    const char *szLogRoot;
    apr_file_t *f_stdin, *nLogFD = NULL, *nLogFDprev = NULL;
    apr_pool_t *pool;
    apr_pool_t *pfile = NULL;
    apr_pool_t *pfile_prev = NULL;
    apr_getopt_t *opt;
    apr_status_t rv;
    char c;
    const char *optarg;
    char *ptr = NULL;

    apr_app_initialize(&argc, &argv, NULL);
    atexit(apr_terminate);

    apr_pool_create(&pool, NULL);
    apr_getopt_init(&opt, pool, argc, argv);
    while ((rv = apr_getopt(opt, "lf", &c, &optarg)) == APR_SUCCESS) {
        switch (c) {
        case 'l':
            use_localtime = 1;
            break;
        case 'f':
            bypass_io = 1;
            break;
        }
    }

    if (rv != APR_EOF) {
        usage(argv[0], NULL /* specific error message already issued */ );
    }

    if (opt->ind + 2 != argc && opt->ind + 3 != argc) {
        usage(argv[0], "Incorrect number of arguments");
    }

    szLogRoot = argv[opt->ind++];

    ptr = strchr(argv[opt->ind], 'M');
    if (ptr) { /* rotation based on file size */
        if (*(ptr+1) == '\0') {
            sRotation = atoi(argv[opt->ind]) * 1048576;
        }
        if (sRotation == 0) {
            usage(argv[0], "Invalid rotation size parameter");
        }
    }
    else { /* rotation based on elapsed time */
        tRotation = atoi(argv[opt->ind]);
        if (tRotation <= 0) {
            usage(argv[0], "Invalid rotation time parameter");
        }
    }
    opt->ind++;

    if (opt->ind < argc) { /* have UTC offset */
        if (use_localtime) {
            usage(argv[0], "UTC offset parameter is not valid with -l");
        }
        utc_offset = atoi(argv[opt->ind]) * 60;
    }

    use_strftime = (strchr(szLogRoot, '%') != NULL);
    if (apr_file_open_stdin(&f_stdin, pool) != APR_SUCCESS) {
        fprintf(stderr, "Unable to open stdin\n");
        exit(1);
    }

    for (;;) {
        nRead = sizeof(buf);
        /*
         * Bypass reading stdin if we are forcing the logfile
         * to be opened as soon as we start. Since we won't be
         * writing anything, we just want to open the file.
         * First time through is the only time we do this
         * since we reset bypass_io after the 1st loop
         */
        if (!bypass_io) {
            if (apr_file_read(f_stdin, buf, &nRead) != APR_SUCCESS) {
                exit(3);
            }
        }
        if (tRotation) {
            now = get_now(use_localtime, utc_offset);
            if (nLogFD != NULL && now >= tLogEnd) {
                nLogFDprev = nLogFD;
                nLogFD = NULL;
            }
        }
        else if (sRotation) {
            apr_finfo_t finfo;
            apr_off_t current_size = -1;

            if ((nLogFD != NULL) &&
                (apr_file_info_get(&finfo, APR_FINFO_SIZE, nLogFD) == APR_SUCCESS)) {
                current_size = finfo.size;
            }

            if (current_size > sRotation) {
                nLogFDprev = nLogFD;
                nLogFD = NULL;
            }
        }
        else {
            fprintf(stderr, "No rotation time or size specified\n");
            exit(2);
        }

        if (nLogFD == NULL) {
            int tLogStart;
            apr_status_t rv;

            if (tRotation) {
                tLogStart = (now / tRotation) * tRotation;
            }
            else {
                tLogStart = get_now(use_localtime, utc_offset);
            }

            if (use_strftime) {
                apr_time_t tNow = apr_time_from_sec(tLogStart);
                apr_time_exp_t e;
                apr_size_t rs;

                apr_time_exp_gmt(&e, tNow);
                apr_strftime(buf2, &rs, sizeof(buf2), szLogRoot, &e);
            }
            else {
                apr_snprintf(buf2, sizeof(buf2), "%s.%010d", szLogRoot, tLogStart);
            }
            tLogEnd = tLogStart + tRotation;
            pfile_prev = pfile;
            apr_pool_create(&pfile, pool);
            rv = apr_file_open(&nLogFD, buf2, APR_WRITE | APR_CREATE | APR_APPEND,
                               APR_OS_DEFAULT, pfile);
            if (rv != APR_SUCCESS) {
                char error[120];

                apr_strerror(rv, error, sizeof error);

                /* Uh-oh. Failed to open the new log file. Try to clear
                 * the previous log file, note the lost log entries,
                 * and keep on truckin'. */
                if (nLogFDprev == NULL) {
                    fprintf(stderr, "Could not open log file '%s' (%s)\n", buf2, error);
                    exit(2);
                }
                else {
                    nLogFD = nLogFDprev;
                    apr_pool_destroy(pfile);
                    pfile = pfile_prev;
                    /* Try to keep this error message constant length
                     * in case it occurs several times. */
                    apr_snprintf(errbuf, sizeof errbuf,
                                 "Resetting log file due to error opening "
                                 "new log file, %10d messages lost: %-25.25s\n",
                                 nMessCount, error);
                    nWrite = strlen(errbuf);
                    apr_file_trunc(nLogFD, 0);
                    if (apr_file_write(nLogFD, errbuf, &nWrite) != APR_SUCCESS) {
                        fprintf(stderr, "Error writing to the file %s\n", buf2);
                        exit(2);
                    }
                }
            }
            else if (nLogFDprev) {
                apr_file_close(nLogFDprev);
                if (pfile_prev) {
                    apr_pool_destroy(pfile_prev);
                }
            }
            nMessCount = 0;
        }
        /*
         * If we just bypassed reading stdin, due to bypass_io,
         * then we have nothing to write, so skip this.
         */
        if (!bypass_io) {
            nWrite = nRead;
            rv = apr_file_write(nLogFD, buf, &nWrite);
            if (rv == APR_SUCCESS && nWrite != nRead) {
                /* buffer partially written, which for rotatelogs means we encountered
                 * an error such as out of space or quota or some other limit reached;
                 * try to write the rest so we get the real error code
                 */
                apr_size_t nWritten = nWrite;

                nRead  = nRead - nWritten;
                nWrite = nRead;
                rv = apr_file_write(nLogFD, buf + nWritten, &nWrite);
            }
            if (nWrite != nRead) {
                char strerrbuf[120];
                apr_off_t cur_offset;
                
                cur_offset = 0;
                if (apr_file_seek(nLogFD, APR_CUR, &cur_offset) != APR_SUCCESS) {
                    cur_offset = -1;
                }
                apr_strerror(rv, strerrbuf, sizeof strerrbuf);
                nMessCount++;
                apr_snprintf(errbuf, sizeof errbuf,
                             "Error %d writing to log file at offset %" APR_OFF_T_FMT ". "
                             "%10d messages lost (%s)\n",
                             rv, cur_offset, nMessCount, strerrbuf);
                nWrite = strlen(errbuf);
                apr_file_trunc(nLogFD, 0);
                if (apr_file_write(nLogFD, errbuf, &nWrite) != APR_SUCCESS) {
                    fprintf(stderr, "Error writing to the file %s\n", buf2);
                exit(2);
                }
            }
            else {
                nMessCount++;
            }
        }
        else {
           /* now worry about reading 'n writing all the time */
           bypass_io = 0;
        }
    }
    /* Of course we never, but prevent compiler warnings */
    return 0;
}
