top_srcdir   = /home/runner/work/apache-ultimate-bad-bot-blocker/apache-ultimate-bad-bot-blocker/zlib-1.2.12/httpd-2.2.25
top_builddir = /home/runner/work/apache-ultimate-bad-bot-blocker/apache-ultimate-bad-bot-blocker/zlib-1.2.12/httpd-2.2.25
srcdir       = /home/runner/work/apache-ultimate-bad-bot-blocker/apache-ultimate-bad-bot-blocker/zlib-1.2.12/httpd-2.2.25/modules/ssl
builddir     = /home/runner/work/apache-ultimate-bad-bot-blocker/apache-ultimate-bad-bot-blocker/zlib-1.2.12/httpd-2.2.25/modules/ssl
VPATH        = /home/runner/work/apache-ultimate-bad-bot-blocker/apache-ultimate-bad-bot-blocker/zlib-1.2.12/httpd-2.2.25/modules/ssl
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#
#   standard stuff
#

include $(top_srcdir)/build/special.mk

#
#   developer stuff
#   (we really don't expect end users to use these targets!)
#

ssl_expr_scan.c: $(top_srcdir)/modules/ssl/ssl_expr_scan.l ssl_expr_parse.h
	flex -Pssl_expr_yy -s -B $(top_srcdir)/modules/ssl/ssl_expr_scan.l
	sed -e '/$$Header:/d' -e "s|\"`pwd`/|\"|g" <lex.ssl_expr_yy.c >ssl_expr_scan.c && rm -f lex.ssl_expr_yy.c

ssl_expr_parse.c ssl_expr_parse.h: $(top_srcdir)/modules/ssl/ssl_expr_parse.y
	yacc -d $(top_srcdir)/modules/ssl/ssl_expr_parse.y
	sed -e 's;yy;ssl_expr_yy;g' \
	    -e "s|\"`pwd`/|\"|g" \
	    -e '/#if defined(c_plusplus) || defined(__cplusplus)/,/#endif/d' \
	    <y.tab.c >ssl_expr_parse.c && rm -f y.tab.c
	sed -e 's;yy;ssl_expr_yy;g' \
	    <y.tab.h >ssl_expr_parse.h && rm -f y.tab.h

