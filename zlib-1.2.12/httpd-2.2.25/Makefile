top_srcdir   = /home/runner/work/apache-ultimate-bad-bot-blocker/apache-ultimate-bad-bot-blocker/zlib-1.2.12/httpd-2.2.25
top_builddir = /home/runner/work/apache-ultimate-bad-bot-blocker/apache-ultimate-bad-bot-blocker/zlib-1.2.12/httpd-2.2.25
srcdir       = /home/runner/work/apache-ultimate-bad-bot-blocker/apache-ultimate-bad-bot-blocker/zlib-1.2.12/httpd-2.2.25
builddir     = /home/runner/work/apache-ultimate-bad-bot-blocker/apache-ultimate-bad-bot-blocker/zlib-1.2.12/httpd-2.2.25
VPATH        = /home/runner/work/apache-ultimate-bad-bot-blocker/apache-ultimate-bad-bot-blocker/zlib-1.2.12/httpd-2.2.25

SUBDIRS = srclib os server modules support
CLEAN_SUBDIRS = test

PROGRAM_NAME         = $(progname)
PROGRAM_SOURCES      = modules.c
PROGRAM_LDADD        = buildmark.o $(HTTPD_LDFLAGS) $(PROGRAM_DEPENDENCIES) $(EXTRA_LIBS) $(AP_LIBS) $(LIBS)
PROGRAM_PRELINK      = $(COMPILE) -c $(top_srcdir)/server/buildmark.c
PROGRAM_DEPENDENCIES = \
  server/libmain.la \
  $(BUILTIN_LIBS) \
  $(MPM_LIB) \
  os/$(OS_DIR)/libos.la

PROGRAMS        = $(PROGRAM_NAME)
TARGETS         = $(PROGRAMS) $(shared_build) $(other_targets)
INSTALL_TARGETS = install-conf install-htdocs install-error install-icons \
	install-other install-cgi install-include install-suexec install-build \
	install-man

DISTCLEAN_TARGETS  = include/ap_config_auto.h include/ap_config_layout.h \
	modules.c config.cache config.log config.status build/config_vars.mk \
	build/rules.mk docs/conf/httpd.conf docs/conf/extra/*.conf shlibtool \
	build/pkg/pkginfo build/config_vars.sh
EXTRACLEAN_TARGETS = configure include/ap_config_auto.h.in generated_lists \
	httpd.spec

include $(top_builddir)/build/rules.mk
include $(top_srcdir)/build/program.mk

install-conf:
	@echo Installing configuration files
	@$(MKINSTALLDIRS) $(DESTDIR)$(sysconfdir) $(DESTDIR)$(sysconfdir)/extra
	@$(MKINSTALLDIRS) $(DESTDIR)$(sysconfdir)/original/extra
	@cd $(top_srcdir)/docs/conf; \
	for i in mime.types magic; do \
	    if test ! -f $(DESTDIR)$(sysconfdir)/$$i; then \
	        $(INSTALL_DATA) $$i $(DESTDIR)$(sysconfdir); \
	    fi; \
	done; \
	for j in $(top_srcdir)/docs/conf $(top_builddir)/docs/conf ; do \
	    cd $$j ; \
	    for i in httpd.conf extra/httpd-*.conf; do \
	    	if [ -f $$i ] ; then \
	    	( \
	    		n_lm=`awk 'BEGIN {n=0} /@@LoadModule@@/ {n+=1} END {print n}' < $$i`; \
	    		if test $$n_lm -eq 0 -o "x$(DSO_MODULES)" = "x"; then \
	    			sed -e 's#@@ServerRoot@@#$(prefix)#g' \
	    				-e 's#@@Port@@#$(PORT)#g' \
	    				-e 's#@@SSLPort@@#$(SSLPORT)#g' \
	    				-e '/@@LoadModule@@/d' \
	    				< $$i; \
	    		else \
	    			sed -n -e '/@@LoadModule@@/q' \
	    				-e 's#@@ServerRoot@@#$(prefix)#g' \
	    				-e 's#@@Port@@#$(PORT)#g' \
	    				-e 's#@@SSLPort@@#$(SSLPORT)#g' \
	    				-e 'p' \
	    				< $$i; \
	    			for j in $(DSO_MODULES) "^EOL^"; do \
	    				if test $$j != "^EOL^"; then \
	    					echo "LoadModule $${j}_module $(rel_libexecdir)/mod_$${j}.so"; \
	    				fi; \
	    			done; \
	    			sed -e '1,/@@LoadModule@@/d' \
	    				-e '/@@LoadModule@@/d' \
	    				-e 's#@@ServerRoot@@#$(prefix)#g' \
	    				-e 's#@@Port@@#$(PORT)#g' \
	    				-e 's#@@SSLPort@@#$(SSLPORT)#g' \
	    				< $$i; \
	    		fi \
	    	) > $(DESTDIR)$(sysconfdir)/original/$$i; \
	    	chmod 0644 $(DESTDIR)$(sysconfdir)/original/$$i; \
	    	file=$$i; \
	    	if [ "$$i" = "httpd.conf" ]; then \
	    		file=`echo $$i|sed s/.*.conf/$(PROGRAM_NAME).conf/`; \
	    	fi; \
	    	if test ! -f $(DESTDIR)$(sysconfdir)/$$file; then \
	    		$(INSTALL_DATA) $(DESTDIR)$(sysconfdir)/original/$$i $(DESTDIR)$(sysconfdir)/$$file; \
	    	fi; \
	    	fi; \
	    done ; \
	done ; \
	if test -f "$(builddir)/envvars-std"; then \
	    cp -p envvars-std $(DESTDIR)$(sbindir); \
	    if test ! -f $(DESTDIR)$(sbindir)/envvars; then \
	        cp -p envvars-std $(DESTDIR)$(sbindir)/envvars ; \
	    fi ; \
	fi

# Create a sanitized config_vars.mk
build/config_vars.out: build/config_vars.mk
	@$(SHELL) build/config_vars.sh < build/config_vars.mk > build/config_vars.out

install-build: build/config_vars.out
	@echo Installing build system files 
	@$(MKINSTALLDIRS) $(DESTDIR)$(installbuilddir) 
	@for f in $(top_srcdir)/build/*.mk build/*.mk; do \
	 $(INSTALL_DATA) $$f $(DESTDIR)$(installbuilddir); \
	done
	@for f in $(top_builddir)/config.nice \
		  $(top_srcdir)/build/mkdir.sh \
		  $(top_srcdir)/build/instdso.sh; do \
	 $(INSTALL_PROGRAM) $$f $(DESTDIR)$(installbuilddir); \
	done
	@$(INSTALL_DATA) build/config_vars.out $(DESTDIR)$(installbuilddir)/config_vars.mk
	@rm build/config_vars.out

htdocs-srcdir = $(top_srcdir)/docs/docroot

docs:
	@if test -d $(top_srcdir)/docs/manual/build; then \
	    cd $(top_srcdir)/docs/manual/build && ./build.sh all; \
	else \
	    echo 'For details on generating the docs, please read:'; \
	    echo '  http://httpd.apache.org/docs-project/docsformat.html'; \
	fi

dox:
	doxygen $(top_srcdir)/docs/doxygen.conf

install-htdocs:
	-@if [ -d $(DESTDIR)$(htdocsdir) ]; then \
           echo "[PRESERVING EXISTING HTDOCS SUBDIR: $(DESTDIR)$(htdocsdir)]"; \
        else \
	    echo Installing HTML documents ; \
	    $(MKINSTALLDIRS) $(DESTDIR)$(htdocsdir) ; \
	    if test -d $(htdocs-srcdir) && test "x$(RSYNC)" != "x" && test -x $(RSYNC) ; then \
		$(RSYNC) --exclude .svn -rlpt --numeric-ids $(htdocs-srcdir)/ $(DESTDIR)$(htdocsdir)/; \
	    else \
		test -d $(htdocs-srcdir) && (cd $(htdocs-srcdir) && cp -rp * $(DESTDIR)$(htdocsdir)) ; \
		cd $(DESTDIR)$(htdocsdir) && find . -name ".svn" -type d -print | xargs rm -rf 2>/dev/null || true; \
	    fi; \
	fi

install-error:
	-@if [ -d $(DESTDIR)$(errordir) ]; then \
           echo "[PRESERVING EXISTING ERROR SUBDIR: $(DESTDIR)$(errordir)]"; \
        else \
	    echo Installing error documents ; \
	    $(MKINSTALLDIRS) $(DESTDIR)$(errordir) ; \
	    cd $(top_srcdir)/docs/error && cp -rp * $(DESTDIR)$(errordir) ; \
	    test "x$(errordir)" != "x" && cd $(DESTDIR)$(errordir) && find . -name ".svn" -type d -print | xargs rm -rf 2>/dev/null || true; \
	fi

install-icons:
	-@if [ -d $(DESTDIR)$(iconsdir) ]; then \
           echo "[PRESERVING EXISTING ICONS SUBDIR: $(DESTDIR)$(iconsdir)]"; \
        else \
	    echo Installing icons ; \
	    $(MKINSTALLDIRS) $(DESTDIR)$(iconsdir) ; \
	    cd $(top_srcdir)/docs/icons && cp -rp * $(DESTDIR)$(iconsdir) ; \
	    test "x$(iconsdir)" != "x" && cd $(DESTDIR)$(iconsdir) && find . -name ".svn" -type d -print | xargs rm -rf 2>/dev/null || true; \
	fi

install-cgi:
	-@if [ -d $(DESTDIR)$(cgidir) ];then \
	    echo "[PRESERVING EXISTING CGI SUBDIR: $(DESTDIR)$(cgidir)]"; \
	else \
	   echo Installing CGIs ; \
	   $(MKINSTALLDIRS) $(DESTDIR)$(cgidir) ; \
	   cd $(top_srcdir)/docs/cgi-examples && cp -rp * $(DESTDIR)$(cgidir) ; \
	   test "x$(cgidir)" != "x" && cd $(DESTDIR)$(cgidir) && find . -name ".svn" -type d -print | xargs rm -rf 2>/dev/null || true; \
	fi

install-other:
	@test -d $(DESTDIR)$(logfiledir) || $(MKINSTALLDIRS) $(DESTDIR)$(logfiledir)
	@test -d $(DESTDIR)$(runtimedir) || $(MKINSTALLDIRS) $(DESTDIR)$(runtimedir)
	@for ext in dll x; do \
		file=apachecore.$$ext; \
		if test -f $$file; then \
			cp -p $$file $(DESTDIR)$(libdir); \
		fi; \
	done; \
	file=httpd.dll; \
	if test -f $$file; then \
		cp -p $$file $(DESTDIR)$(bindir); \
	fi;

INSTALL_HEADERS = \
	include/*.h \
	$(srcdir)/include/*.h \
	$(srcdir)/os/$(OS_DIR)/os.h \
	$(srcdir)/server/mpm/$(MPM_SUBDIR_NAME)/*.h \
	$(srcdir)/modules/aaa/mod_auth.h \
	$(srcdir)/modules/database/mod_dbd.h \
	$(srcdir)/modules/dav/main/mod_dav.h \
	$(srcdir)/modules/filters/mod_include.h \
	$(srcdir)/modules/generators/mod_cgi.h \
	$(srcdir)/modules/generators/mod_status.h \
	$(srcdir)/modules/loggers/mod_log_config.h \
	$(srcdir)/modules/http/mod_core.h \
	$(srcdir)/modules/mappers/mod_rewrite.h \
	$(srcdir)/modules/proxy/mod_proxy.h \
	$(srcdir)/modules/ssl/mod_ssl.h \
	$(srcdir)/os/$(OS_DIR)/*.h

install-include:
	@echo Installing header files
	@$(MKINSTALLDIRS) $(DESTDIR)$(includedir)
	@for hdr in $(INSTALL_HEADERS); do \
	  $(INSTALL_DATA) $$hdr $(DESTDIR)$(includedir); \
	done

install-man:
	@echo Installing man pages and online manual
	@test -d $(DESTDIR)$(mandir)      || $(MKINSTALLDIRS) $(DESTDIR)$(mandir)
	@test -d $(DESTDIR)$(mandir)/man1 || $(MKINSTALLDIRS) $(DESTDIR)$(mandir)/man1
	@test -d $(DESTDIR)$(mandir)/man8 || $(MKINSTALLDIRS) $(DESTDIR)$(mandir)/man8
	@test -d $(DESTDIR)$(manualdir)   || $(MKINSTALLDIRS) $(DESTDIR)$(manualdir)
	@cp -p $(top_srcdir)/docs/man/*.1 $(DESTDIR)$(mandir)/man1
	@cp -p $(top_srcdir)/docs/man/*.8 $(DESTDIR)$(mandir)/man8
	@if test "x$(RSYNC)" != "x" && test -x $(RSYNC) ; then \
	  $(RSYNC) --exclude .svn -rlpt --numeric-ids $(top_srcdir)/docs/manual/ $(DESTDIR)$(manualdir)/; \
	else \
	  cd $(top_srcdir)/docs/manual && cp -rp * $(DESTDIR)$(manualdir); \
	  cd $(DESTDIR)$(manualdir) && find . -name ".svn" -type d -print | xargs rm -rf 2>/dev/null || true; \
	fi

install-suexec:
	@if test -f $(builddir)/support/suexec; then \
            test -d $(DESTDIR)$(sbindir) || $(MKINSTALLDIRS) $(DESTDIR)$(sbindir); \
            $(INSTALL_PROGRAM) $(top_builddir)/support/suexec $(DESTDIR)$(sbindir); \
            chmod 4755 $(DESTDIR)$(sbindir)/suexec; \
	fi

suexec:
	cd support && $(MAKE) suexec

x-local-distclean:
	@rm -rf autom4te.cache

include $(top_srcdir)/os/os2/core.mk
