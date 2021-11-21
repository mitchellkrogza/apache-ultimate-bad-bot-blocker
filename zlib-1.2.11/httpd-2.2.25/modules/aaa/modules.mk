mod_authn_file.la: mod_authn_file.slo
	$(SH_LINK) -rpath $(libexecdir) -module -avoid-version  mod_authn_file.lo $(MOD_AUTHN_FILE_LDADD)
mod_authn_dbm.la: mod_authn_dbm.slo
	$(SH_LINK) -rpath $(libexecdir) -module -avoid-version  mod_authn_dbm.lo $(MOD_AUTHN_DBM_LDADD)
mod_authn_anon.la: mod_authn_anon.slo
	$(SH_LINK) -rpath $(libexecdir) -module -avoid-version  mod_authn_anon.lo $(MOD_AUTHN_ANON_LDADD)
mod_authn_dbd.la: mod_authn_dbd.slo
	$(SH_LINK) -rpath $(libexecdir) -module -avoid-version  mod_authn_dbd.lo $(MOD_AUTHN_DBD_LDADD)
mod_authn_default.la: mod_authn_default.slo
	$(SH_LINK) -rpath $(libexecdir) -module -avoid-version  mod_authn_default.lo $(MOD_AUTHN_DEFAULT_LDADD)
mod_authz_host.la: mod_authz_host.slo
	$(SH_LINK) -rpath $(libexecdir) -module -avoid-version  mod_authz_host.lo $(MOD_AUTHZ_HOST_LDADD)
mod_authz_groupfile.la: mod_authz_groupfile.slo
	$(SH_LINK) -rpath $(libexecdir) -module -avoid-version  mod_authz_groupfile.lo $(MOD_AUTHZ_GROUPFILE_LDADD)
mod_authz_user.la: mod_authz_user.slo
	$(SH_LINK) -rpath $(libexecdir) -module -avoid-version  mod_authz_user.lo $(MOD_AUTHZ_USER_LDADD)
mod_authz_dbm.la: mod_authz_dbm.slo
	$(SH_LINK) -rpath $(libexecdir) -module -avoid-version  mod_authz_dbm.lo $(MOD_AUTHZ_DBM_LDADD)
mod_authz_owner.la: mod_authz_owner.slo
	$(SH_LINK) -rpath $(libexecdir) -module -avoid-version  mod_authz_owner.lo $(MOD_AUTHZ_OWNER_LDADD)
mod_authz_default.la: mod_authz_default.slo
	$(SH_LINK) -rpath $(libexecdir) -module -avoid-version  mod_authz_default.lo $(MOD_AUTHZ_DEFAULT_LDADD)
mod_auth_basic.la: mod_auth_basic.slo
	$(SH_LINK) -rpath $(libexecdir) -module -avoid-version  mod_auth_basic.lo $(MOD_AUTH_BASIC_LDADD)
mod_auth_digest.la: mod_auth_digest.slo
	$(SH_LINK) -rpath $(libexecdir) -module -avoid-version  mod_auth_digest.lo $(MOD_AUTH_DIGEST_LDADD)
DISTCLEAN_TARGETS = modules.mk
static = 
shared =  mod_authn_file.la mod_authn_dbm.la mod_authn_anon.la mod_authn_dbd.la mod_authn_default.la mod_authz_host.la mod_authz_groupfile.la mod_authz_user.la mod_authz_dbm.la mod_authz_owner.la mod_authz_default.la mod_auth_basic.la mod_auth_digest.la
