mod_dumpio.la: mod_dumpio.slo
	$(SH_LINK) -rpath $(libexecdir) -module -avoid-version  mod_dumpio.lo $(MOD_DUMPIO_LDADD)
DISTCLEAN_TARGETS = modules.mk
static = 
shared =  mod_dumpio.la
