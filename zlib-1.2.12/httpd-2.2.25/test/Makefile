top_srcdir   = /home/runner/work/apache-ultimate-bad-bot-blocker/apache-ultimate-bad-bot-blocker/zlib-1.2.12/httpd-2.2.25
top_builddir = /home/runner/work/apache-ultimate-bad-bot-blocker/apache-ultimate-bad-bot-blocker/zlib-1.2.12/httpd-2.2.25
srcdir       = /home/runner/work/apache-ultimate-bad-bot-blocker/apache-ultimate-bad-bot-blocker/zlib-1.2.12/httpd-2.2.25/test
builddir     = /home/runner/work/apache-ultimate-bad-bot-blocker/apache-ultimate-bad-bot-blocker/zlib-1.2.12/httpd-2.2.25/test
VPATH        = /home/runner/work/apache-ultimate-bad-bot-blocker/apache-ultimate-bad-bot-blocker/zlib-1.2.12/httpd-2.2.25/test

# no targets: we don't want to build anything by default. if you want the
# test programs, then "make test"
TARGETS =

PROGRAMS =

PROGRAM_LDADD        = $(EXTRA_LDFLAGS) $(PROGRAM_DEPENDENCIES) $(EXTRA_LIBS)
PROGRAM_DEPENDENCIES =  \
	$(top_srcdir)/srclib/apr-util/libaprutil.la \
	$(top_srcdir)/srclib/apr/libapr.la

include $(top_builddir)/build/rules.mk

test: $(PROGRAMS)

# example for building a test proggie
# dbu_OBJECTS = dbu.lo
# dbu: $(dbu_OBJECTS)
#	$(LINK) $(dbu_OBJECTS) $(PROGRAM_LDADD)
