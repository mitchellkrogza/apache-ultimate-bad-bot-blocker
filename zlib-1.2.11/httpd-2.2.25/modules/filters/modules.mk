mod_reqtimeout.la: mod_reqtimeout.slo
	$(SH_LINK) -rpath $(libexecdir) -module -avoid-version  mod_reqtimeout.lo $(MOD_REQTIMEOUT_LDADD)
mod_ext_filter.la: mod_ext_filter.slo
	$(SH_LINK) -rpath $(libexecdir) -module -avoid-version  mod_ext_filter.lo $(MOD_EXT_FILTER_LDADD)
mod_include.la: mod_include.slo
	$(SH_LINK) -rpath $(libexecdir) -module -avoid-version  mod_include.lo $(MOD_INCLUDE_LDADD)
mod_filter.la: mod_filter.slo
	$(SH_LINK) -rpath $(libexecdir) -module -avoid-version  mod_filter.lo $(MOD_FILTER_LDADD)
mod_substitute.la: mod_substitute.slo
	$(SH_LINK) -rpath $(libexecdir) -module -avoid-version  mod_substitute.lo $(MOD_SUBSTITUTE_LDADD)
mod_deflate.la: mod_deflate.slo
	$(SH_LINK) -rpath $(libexecdir) -module -avoid-version  mod_deflate.lo $(MOD_DEFLATE_LDADD)
DISTCLEAN_TARGETS = modules.mk
static = 
shared =  mod_reqtimeout.la mod_ext_filter.la mod_include.la mod_filter.la mod_substitute.la mod_deflate.la
