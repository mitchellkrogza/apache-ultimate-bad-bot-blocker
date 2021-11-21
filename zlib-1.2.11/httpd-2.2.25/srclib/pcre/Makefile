top_srcdir   = /home/runner/work/apache-ultimate-bad-bot-blocker/apache-ultimate-bad-bot-blocker/zlib-1.2.11/httpd-2.2.25
top_builddir = /home/runner/work/apache-ultimate-bad-bot-blocker/apache-ultimate-bad-bot-blocker/zlib-1.2.11/httpd-2.2.25
srcdir       = /home/runner/work/apache-ultimate-bad-bot-blocker/apache-ultimate-bad-bot-blocker/zlib-1.2.11/httpd-2.2.25/srclib/pcre
builddir     = /home/runner/work/apache-ultimate-bad-bot-blocker/apache-ultimate-bad-bot-blocker/zlib-1.2.11/httpd-2.2.25/srclib/pcre
VPATH        = /home/runner/work/apache-ultimate-bad-bot-blocker/apache-ultimate-bad-bot-blocker/zlib-1.2.11/httpd-2.2.25/srclib/pcre
LTLIBRARY_NAME = libpcre.la
LTLIBRARY_SOURCES = maketables.c get.c study.c pcre.c

CLEAN_TARGETS = dftables chartables.c
DISTCLEAN_TARGETS = pcre.h pcre-config config.h config.log config.status $(CLEAN_TARGETS)

include $(top_srcdir)/build/ltlib.mk

config.h:
	touch $@

$(LTLIBRARY_OBJECTS) dftables.lo: config.h

dftables: dftables.lo
	$(LINK) $(EXTRA_LDFLAGS) dftables.lo $(EXTRA_LIBS)

$(srcdir)/chartables.c: dftables
	./dftables $@

pcre.lo: $(srcdir)/chartables.c
