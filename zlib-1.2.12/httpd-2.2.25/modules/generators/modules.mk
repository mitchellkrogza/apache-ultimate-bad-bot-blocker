mod_status.la: mod_status.slo
	$(SH_LINK) -rpath $(libexecdir) -module -avoid-version  mod_status.lo $(MOD_STATUS_LDADD)
mod_autoindex.la: mod_autoindex.slo
	$(SH_LINK) -rpath $(libexecdir) -module -avoid-version  mod_autoindex.lo $(MOD_AUTOINDEX_LDADD)
mod_asis.la: mod_asis.slo
	$(SH_LINK) -rpath $(libexecdir) -module -avoid-version  mod_asis.lo $(MOD_ASIS_LDADD)
mod_info.la: mod_info.slo
	$(SH_LINK) -rpath $(libexecdir) -module -avoid-version  mod_info.lo $(MOD_INFO_LDADD)
mod_cgi.la: mod_cgi.slo
	$(SH_LINK) -rpath $(libexecdir) -module -avoid-version  mod_cgi.lo $(MOD_CGI_LDADD)
DISTCLEAN_TARGETS = modules.mk
static = 
shared =  mod_status.la mod_autoindex.la mod_asis.la mod_info.la mod_cgi.la
