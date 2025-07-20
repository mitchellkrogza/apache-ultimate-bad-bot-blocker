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
#
# The build environment was originally provided by Sascha Schumann.

include  $(top_builddir)/build/config_vars.mk 

# Combine all of the flags together in the proper order so that
# the user-defined flags can always override the configure ones, if needed.
# Note that includes are listed after the flags because -I options have
# left-to-right precedence and CPPFLAGS may include user-defined overrides.
#
ALL_CFLAGS   = $(EXTRA_CFLAGS) $(NOTEST_CFLAGS) $(CFLAGS)
ALL_CPPFLAGS = $(DEFS) $(EXTRA_CPPFLAGS) $(NOTEST_CPPFLAGS) $(CPPFLAGS)
ALL_CXXFLAGS = $(EXTRA_CXXFLAGS) $(NOTEST_CXXFLAGS) $(CXXFLAGS)
ALL_LDFLAGS  = $(EXTRA_LDFLAGS) $(NOTEST_LDFLAGS) $(LDFLAGS)
ALL_LIBS     = $(EXTRA_LIBS) $(NOTEST_LIBS) $(LIBS)
ALL_INCLUDES = $(INCLUDES) $(EXTRA_INCLUDES)

# Compile commands

BASE_CC  = $(CC) $(ALL_CFLAGS) $(ALL_CPPFLAGS) $(ALL_INCLUDES)
BASE_CXX = $(CXX) $(ALL_CXXFLAGS) $(ALL_CPPFLAGS) $(ALL_INCLUDES)

COMPILE      = $(BASE_CC) 
CXX_COMPILE  = $(BASE_CXX) 

SH_COMPILE     = $(LIBTOOL) --mode=compile $(BASE_CC) -prefer-pic -c $< && touch $@
SH_CXX_COMPILE = $(LIBTOOL) --mode=compile $(BASE_CXX) -prefer-pic -c $< && touch $@

LT_COMPILE     = $(LIBTOOL) --mode=compile $(COMPILE) -prefer-non-pic -static -c $< && touch $@
LT_CXX_COMPILE = $(LIBTOOL) --mode=compile $(CXX_COMPILE) -prefer-non-pic -static -c $< && touch $@

# Link-related commands

LINK     = $(LIBTOOL) --mode=link $(CC) $(ALL_CFLAGS)  $(LT_LDFLAGS) $(ALL_LDFLAGS) -o $@
SH_LINK  = $(SH_LIBTOOL) --mode=link $(CC) $(ALL_CFLAGS) $(LT_LDFLAGS) $(ALL_LDFLAGS) $(SH_LDFLAGS) $(CORE_IMPLIB) $(SH_LIBS) -o $@
MOD_LINK = $(LIBTOOL) --mode=link $(CC) $(ALL_CFLAGS) -static $(LT_LDFLAGS) $(ALL_LDFLAGS) -o $@

# Cross compile commands

# Helper programs

INSTALL_DATA = $(INSTALL) -m 644
INSTALL_PROGRAM = $(INSTALL) -m 755 $(INSTALL_PROG_FLAGS)

#
# Standard build rules
#
all: all-recursive
depend: depend-recursive
clean: clean-recursive
distclean: distclean-recursive
extraclean: extraclean-recursive
install: install-recursive
shared-build: shared-build-recursive

all-recursive install-recursive depend-recursive:
	@otarget=`echo $@|sed s/-recursive//`; \
	list=' $(BUILD_SUBDIRS) $(SUBDIRS)'; \
	for i in $$list; do \
	    if test -d "$$i"; then \
		target="$$otarget"; \
		echo "Making $$target in $$i"; \
		if test "$$i" = "."; then \
			made_local=yes; \
			target="local-$$target"; \
		fi; \
		(cd $$i && $(MAKE) $$target) || exit 1; \
	    fi; \
	done; \
	if test "$$otarget" = "all" && test -z '$(TARGETS)'; then \
	    made_local=yes; \
	fi; \
	if test "$$made_local" != "yes"; then \
	    $(MAKE) "local-$$otarget" || exit 1; \
	fi

clean-recursive distclean-recursive extraclean-recursive:
	@otarget=`echo $@|sed s/-recursive//`; \
	list='$(CLEAN_SUBDIRS) $(SUBDIRS)'; \
	for i in $$list; do \
	    if test -d "$$i"; then \
		target="$$otarget"; \
		echo "Making $$target in $$i"; \
		if test "$$i" = "."; then \
			made_local=yes; \
			target="local-$$target"; \
		fi; \
		(cd $$i && $(MAKE) $$target); \
	    fi; \
	done; \
	if test "$$otarget" = "all" && test -z '$(TARGETS)'; then \
	    made_local=yes; \
	fi; \
	if test "$$made_local" != "yes"; then \
	    $(MAKE) "local-$$otarget"; \
	fi

shared-build-recursive:
	@if test `pwd` = "$(top_builddir)"; then \
	    $(PRE_SHARED_CMDS) ; \
	fi; \
	list='$(SUBDIRS)'; for i in $$list; do \
	    target="shared-build"; \
	    if test "$$i" = "."; then \
		made_local=yes; \
		target="local-shared-build"; \
	    fi; \
	    if test "$$i" != "srclib"; then \
		(cd $$i && $(MAKE) $$target) || exit 1; \
	    fi; \
	done; \
	if test -f 'modules.mk'; then \
	    if test -n '$(SHARED_TARGETS)'; then \
		echo "Building shared: $(SHARED_TARGETS)"; \
		if test "$$made_local" != "yes"; then \
			$(MAKE) "local-shared-build" || exit 1; \
		fi; \
	    fi; \
	fi; \
	if test `pwd` = "$(top_builddir)"; then \
		$(POST_SHARED_CMDS) ; \
	fi

local-all: $(TARGETS)

local-shared-build: $(SHARED_TARGETS)

local-depend: x-local-depend
	@if test -n "`ls $(srcdir)/*.c 2> /dev/null`"; then \
		rm -f .deps; \
		list='$(srcdir)/*.c'; \
		for i in $$list; do \
			$(MKDEP) $(ALL_CPPFLAGS) $(ALL_INCLUDES) $$i | sed 's/\.o:/.lo:/' >> .deps; \
		done; \
	fi

local-clean: x-local-clean
	rm -f *.o *.lo *.slo *.obj *.a *.la $(CLEAN_TARGETS) $(TARGETS)
	rm -rf .libs

local-distclean: local-clean x-local-distclean
	rm -f .deps Makefile $(DISTCLEAN_TARGETS)

local-extraclean: local-distclean x-local-extraclean
	@if test -n "$(EXTRACLEAN_TARGETS)"; then \
	    echo "rm -f $(EXTRACLEAN_TARGETS)"; \
	    rm -f $(EXTRACLEAN_TARGETS) ; \
	fi

program-install: $(TARGETS) $(SHARED_TARGETS)
	@if test -n '$(PROGRAMS)'; then \
	    test -d $(DESTDIR)$(sbindir) || $(MKINSTALLDIRS) $(DESTDIR)$(sbindir); \
	    list='$(PROGRAMS)'; for i in $$list; do \
	        $(INSTALL_PROGRAM) $$i $(DESTDIR)$(sbindir); \
	    done; \
	fi

local-install: program-install $(INSTALL_TARGETS)

# to be filled in by the actual Makefile if extra commands are needed
x-local-depend x-local-clean x-local-distclean x-local-extraclean:

#
# Implicit rules for creating outputs from input files
#
CXX_SUFFIX = cpp
SHLIB_SUFFIX = so

.SUFFIXES:
.SUFFIXES: .S .c .$(CXX_SUFFIX) .lo .o .s .y .l .slo .def .la

.c.o:
	$(COMPILE) -c $<

.s.o:
	$(COMPILE) -c $<

.c.lo:
	$(LT_COMPILE)

.s.lo:
	$(LT_COMPILE)

.c.slo:
	$(SH_COMPILE)

.$(CXX_SUFFIX).lo:
	$(LT_CXX_COMPILE)

.$(CXX_SUFFIX).slo:
	$(SH_CXX_COMPILE)

.y.c:
	$(YACC) $(YFLAGS) $< && mv y.tab.c $*.c
	if test -f y.tab.h; then \
	if cmp -s y.tab.h $*.h; then rm -f y.tab.h; else mv y.tab.h $*.h; fi; \
	else :; fi

.l.c:
	$(LEX) $(LFLAGS) $< && mv $(LEX_OUTPUT_ROOT).c $@

# Makes an import library from a def file
.def.la:
	$(LIBTOOL) --mode=compile $(MK_IMPLIB) -o $@ $<

#
# Dependencies
#
include  $(builddir)/.deps 

.PHONY: all all-recursive install-recursive local-all $(PHONY_TARGETS) \
	shared-build shared-build-recursive local-shared-build \
	depend depend-recursive local-depend x-local-depend \
	clean clean-recursive local-clean x-local-clean \
	distclean distclean-recursive local-distclean x-local-distclean \
	extraclean extraclean-recursive local-extraclean x-local-extraclean \
	install local-install docs $(INSTALL_TARGETS)

