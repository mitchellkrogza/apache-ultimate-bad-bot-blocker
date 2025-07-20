# *****************************************************************************************************************
# *****************************************************************************************************************
# *****************************************************************************************************************
# *****************************************************************************************************************
# *****************************************************************************************************************
# *****************************************************************************************************************

# *************************************************
# GENERATE THE CENTOS6 VERSION OF THE BLOCKER
# *************************************************

# *******************************************************************************
# PRINT VERSION, SCRIPT RUNTIME and UPDATE INFORMATION INTO GLOBALBLACKLIST FILES
# *******************************************************************************

printf '%s\n%s\n%s%s\n%s%s\n%s%s\n%s%s\n%s\n%s\n' "${startmarker}" "###################################################" "### Version: " "${my_git_tag}" "### Updated: " "${now}" "### Bad Referrer Count: " "${bad_referrers}" "### Bad Bot Count: " "${bad_bots}" "###################################################" "${endmarker}" >> ${tmpapacheA}
mv ${tmpapacheA} ${inputdbA}
ed -s ${inputdbA}<<\IN
1,/### Version Information #/d
/### Version Information ##/,$d
,d
.r /home/travis/build/mitchellkrogza/apache-ultimate-bad-bot-blocker/.dev-tools/centos6.template
/### Version Information #/x
.t.
.,/### Version Information ##/-d
#,p
#,p used to print output replaced with w below to write
w /home/travis/build/mitchellkrogza/apache-ultimate-bad-bot-blocker/.dev-tools/centos6.template
q
IN
rm ${inputdbA}

# ************************************
# GOOD USER AGENTS - Create and Insert
# ************************************

printf '%s\n' "${start1}" >> ${tmpapache1}
while IFS= read -r LINE
do
printf '%s"%s%s%s" %s\n' "BrowserMatchNoCase " "^(.*?)(\b" "${LINE}" "\b)(.*)$" "${action1}" >> ${tmpapache1}
done < ${input1}
printf '%s\n' "${end1}"  >> ${tmpapache1}
mv ${tmpapache1} ${inputdb1}
ed -s ${inputdb1}<<\IN
1,/# START GOOD BOTS ### DO NOT EDIT THIS LINE AT ALL ###/d
/# END GOOD BOTS ### DO NOT EDIT THIS LINE AT ALL ###/,$d
,d
.r /home/travis/build/mitchellkrogza/apache-ultimate-bad-bot-blocker/.dev-tools/centos6.template
/# START GOOD BOTS ### DO NOT EDIT THIS LINE AT ALL ###/x
.t.
.,/# END GOOD BOTS ### DO NOT EDIT THIS LINE AT ALL ###/-d
#,p
#,p used to print output replaced with w below to write
w /home/travis/build/mitchellkrogza/apache-ultimate-bad-bot-blocker/.dev-tools/centos6.template
q
IN
rm ${inputdb1}

# ********************************
# ALLOWED BOTS - Create and Insert
# ********************************

printf '%s\n' "${start2}" >> ${tmpapache2}
while IFS= read -r LINE
do
printf '%s"%s%s%s" %s\n' "BrowserMatchNoCase " "^(.*?)(\b" "${LINE}" "\b)(.*)$" "${action1}" >> ${tmpapache2}
done < ${input2}
printf '%s\n' "${end2}"  >> ${tmpapache2}
mv ${tmpapache2} ${inputdb2}
ed -s ${inputdb2}<<\IN
1,/# START ALLOWED BOTS ### DO NOT EDIT THIS LINE AT ALL ###/d
/# END ALLOWED BOTS ### DO NOT EDIT THIS LINE AT ALL ###/,$d
,d
.r /home/travis/build/mitchellkrogza/apache-ultimate-bad-bot-blocker/.dev-tools/centos6.template
/# START ALLOWED BOTS ### DO NOT EDIT THIS LINE AT ALL ###/x
.t.
.,/# END ALLOWED BOTS ### DO NOT EDIT THIS LINE AT ALL ###/-d
w /home/travis/build/mitchellkrogza/apache-ultimate-bad-bot-blocker/.dev-tools/centos6.template
q
IN
rm ${inputdb2}

# ********************************
# LIMITED BOTS - Create and Insert
# ********************************

printf '%s\n' "${start3}" >> ${tmpapache3}
while IFS= read -r LINE
do
printf '%s"%s%s%s" %s\n' "BrowserMatchNoCase " "^(.*?)(\b" "${LINE}" "\b)(.*)$" "${action1}" >> ${tmpapache3}
done < ${input3}
printf '%s\n' "${end3}"  >> ${tmpapache3}
mv ${tmpapache3} ${inputdb3}
ed -s ${inputdb3}<<\IN
1,/# START LIMITED BOTS ### DO NOT EDIT THIS LINE AT ALL ###/d
/# END LIMITED BOTS ### DO NOT EDIT THIS LINE AT ALL ###/,$d
,d
.r /home/travis/build/mitchellkrogza/apache-ultimate-bad-bot-blocker/.dev-tools/centos6.template
/# START LIMITED BOTS ### DO NOT EDIT THIS LINE AT ALL ###/x
.t.
.,/# END LIMITED BOTS ### DO NOT EDIT THIS LINE AT ALL ###/-d
w /home/travis/build/mitchellkrogza/apache-ultimate-bad-bot-blocker/.dev-tools/centos6.template
q
IN
rm ${inputdb3}

# ****************************
# BAD BOTS - Create and Insert
# ****************************

printf '%s\n' "${start4}" >> ${tmpapache4}
while IFS= read -r LINE
do
printf '%s"%s%s%s" %s\n' "BrowserMatchNoCase " "^(.*?)(\b" "${LINE}" "\b)(.*)$" "${action2}" >> ${tmpapache4}
done < ${input4}
printf '%s\n' "${end4}"  >> ${tmpapache4}
mv ${tmpapache4} ${inputdb4}
ed -s ${inputdb4}<<\IN
1,/# START BAD BOTS ### DO NOT EDIT THIS LINE AT ALL ###/d
/# END BAD BOTS ### DO NOT EDIT THIS LINE AT ALL ###/,$d
,d
.r /home/travis/build/mitchellkrogza/apache-ultimate-bad-bot-blocker/.dev-tools/centos6.template
/# START BAD BOTS ### DO NOT EDIT THIS LINE AT ALL ###/x
.t.
.,/# END BAD BOTS ### DO NOT EDIT THIS LINE AT ALL ###/-d
w /home/travis/build/mitchellkrogza/apache-ultimate-bad-bot-blocker/.dev-tools/centos6.template
q
IN
rm ${inputdb4}

# ********************************
# BAD REFERERS - Create and Insert
# ********************************

printf '%s\n' "${start5}" >> ${tmpapache5}
while IFS= read -r LINE
do
printf '%s\n' "${LINE}" >> ${tmpapache5}
done < ${input5}
printf '%s\n' "${end5}"  >> ${tmpapache5}
mv ${tmpapache5} ${inputdb5}
ed -s ${inputdb5}<<\IN
1,/# START BAD REFERERS ### DO NOT EDIT THIS LINE AT ALL ###/d
/# END BAD REFERERS ### DO NOT EDIT THIS LINE AT ALL ###/,$d
,d
.r /home/travis/build/mitchellkrogza/apache-ultimate-bad-bot-blocker/.dev-tools/centos6.template
/# START BAD REFERERS ### DO NOT EDIT THIS LINE AT ALL ###/x
.t.
.,/# END BAD REFERERS ### DO NOT EDIT THIS LINE AT ALL ###/-d
w /home/travis/build/mitchellkrogza/apache-ultimate-bad-bot-blocker/.dev-tools/centos6.template
q
IN
rm ${inputdb5}

# ************************************
# GOOGLE IP RANGES - Create and Insert
# ************************************

printf '%s\n' "${start6}" >> ${tmpapache6}
while IFS= read -r LINE
do
printf '%s%s\n' "Allow from " "${LINE}" >> ${tmpapache6}
done < ${input6}
printf '%s\n' "${end6}"  >> ${tmpapache6}
mv ${tmpapache6} ${inputdb6}
ed -s ${inputdb6}<<\IN
1,/# START GOOGLE IP RANGES ### DO NOT EDIT THIS LINE AT ALL ###/d
/# END GOOGLE IP RANGES ### DO NOT EDIT THIS LINE AT ALL ###/,$d
,d
.r /home/travis/build/mitchellkrogza/apache-ultimate-bad-bot-blocker/.dev-tools/centos6.template
/# START GOOGLE IP RANGES ### DO NOT EDIT THIS LINE AT ALL ###/x
.t.
.,/# END GOOGLE IP RANGES ### DO NOT EDIT THIS LINE AT ALL ###/-d
w /home/travis/build/mitchellkrogza/apache-ultimate-bad-bot-blocker/.dev-tools/centos6.template
q
IN
rm ${inputdb6}

# **********************************
# BING IP RANGES - Create and Insert
# **********************************

printf '%s\n' "${start7}" >> ${tmpapache7}
while IFS= read -r LINE
do
printf '%s%s\n' "Allow from " "${LINE}" >> ${tmpapache7}
done < ${input7}
printf '%s\n' "${end7}"  >> ${tmpapache7}
mv ${tmpapache7} ${inputdb7}
ed -s ${inputdb7}<<\IN
1,/# START BING IP RANGES ### DO NOT EDIT THIS LINE AT ALL ###/d
/# END BING IP RANGES ### DO NOT EDIT THIS LINE AT ALL ###/,$d
,d
.r /home/travis/build/mitchellkrogza/apache-ultimate-bad-bot-blocker/.dev-tools/centos6.template
/# START BING IP RANGES ### DO NOT EDIT THIS LINE AT ALL ###/x
.t.
.,/# END BING IP RANGES ### DO NOT EDIT THIS LINE AT ALL ###/-d
w /home/travis/build/mitchellkrogza/apache-ultimate-bad-bot-blocker/.dev-tools/centos6.template
q
IN
rm ${inputdb7}

# *********************************************
# Wordpress Theme Detectors - Create and Insert
# *********************************************

printf '%s\n' "${start8}" >> ${tmpapache8}
while IFS= read -r LINE
do
printf '%s%s\n' "deny from " "${LINE}" >> ${tmpapache8}
done < ${input8}
printf '%s\n' "${end8}"  >> ${tmpapache8}
mv ${tmpapache8} ${inputdb8}
ed -s ${inputdb8}<<\IN
1,/# START WP THEME DETECTORS ### DO NOT EDIT THIS LINE AT ALL ###/d
/# END WP THEME DETECTORS ### DO NOT EDIT THIS LINE AT ALL ###/,$d
,d
.r /home/travis/build/mitchellkrogza/apache-ultimate-bad-bot-blocker/.dev-tools/centos6.template
/# START WP THEME DETECTORS ### DO NOT EDIT THIS LINE AT ALL ###/x
.t.
.,/# END WP THEME DETECTORS ### DO NOT EDIT THIS LINE AT ALL ###/-d
w /home/travis/build/mitchellkrogza/apache-ultimate-bad-bot-blocker/.dev-tools/centos6.template
q
IN
rm ${inputdb8}

# *******************************
# Nibbler SEO - Create and Insert
# *******************************

printf '%s\n' "${start9}" >> ${tmpapache9}
while IFS= read -r LINE
do
printf '%s%s\n' "deny from " "${LINE}" >> ${tmpapache9}
done < ${input9}
printf '%s\n' "${end9}"  >> ${tmpapache9}
mv ${tmpapache9} ${inputdb9}
ed -s ${inputdb9}<<\IN
1,/# START NIBBLER ### DO NOT EDIT THIS LINE AT ALL ###/d
/# END NIBBLER ### DO NOT EDIT THIS LINE AT ALL ###/,$d
,d
.r /home/travis/build/mitchellkrogza/apache-ultimate-bad-bot-blocker/.dev-tools/centos6.template
/# START NIBBLER ### DO NOT EDIT THIS LINE AT ALL ###/x
.t.
.,/# END NIBBLER ### DO NOT EDIT THIS LINE AT ALL ###/-d
w /home/travis/build/mitchellkrogza/apache-ultimate-bad-bot-blocker/.dev-tools/centos6.template
q
IN
rm ${inputdb9}

# ****************************************
# CLOUDFLARE IP RANGES - Create and Insert
# ****************************************

printf '%s\n' "${start10}" >> ${tmpapache10}
while IFS= read -r LINE
do
printf '%s%s\n' "Allow from " "${LINE}" >> ${tmpapache10}
done < ${input10}
printf '%s\n' "${end10}"  >> ${tmpapache10}
mv ${tmpapache10} ${inputdb10}
ed -s ${inputdb10}<<\IN
1,/# START CLOUDFLARE IP RANGES ### DO NOT EDIT THIS LINE AT ALL ###/d
/# END CLOUDFLARE IP RANGES ### DO NOT EDIT THIS LINE AT ALL ###/,$d
,d
.r /home/travis/build/mitchellkrogza/apache-ultimate-bad-bot-blocker/.dev-tools/centos6.template
/# START CLOUDFLARE IP RANGES ### DO NOT EDIT THIS LINE AT ALL ###/x
.t.
.,/# END CLOUDFLARE IP RANGES ### DO NOT EDIT THIS LINE AT ALL ###/-d
w /home/travis/build/mitchellkrogza/apache-ultimate-bad-bot-blocker/.dev-tools/centos6.template
q
IN
rm ${inputdb10}

# Copy files to correct folder
# **********************************************
#sudo cp ${apache3} /home/travis/build/mitchellkrogza/apache-ultimate-bad-bot-blocker/_other_distros/CentOS6/conf.d/globalblacklist.conf

# *****************************************************************************************************************
# *****************************************************************************************************************
# *****************************************************************************************************************
# *****************************************************************************************************************
# *****************************************************************************************************************
# *****************************************************************************************************************

# *************************************************
# GENERATE THE CENTOS7 VERSION OF THE BLOCKER
# *************************************************

# *******************************************************************************
# PRINT VERSION, SCRIPT RUNTIME and UPDATE INFORMATION INTO GLOBALBLACKLIST FILES
# *******************************************************************************

printf '%s\n%s\n%s%s\n%s%s\n%s%s\n%s%s\n%s\n%s\n' "${startmarker}" "###################################################" "### Version: " "${my_git_tag}" "### Updated: " "${now}" "### Bad Referrer Count: " "${bad_referrers}" "### Bad Bot Count: " "${bad_bots}" "###################################################" "${endmarker}" >> ${tmpapacheA}
mv ${tmpapacheA} ${inputdbA}
ed -s ${inputdbA}<<\IN
1,/### Version Information #/d
/### Version Information ##/,$d
,d
.r /home/travis/build/mitchellkrogza/apache-ultimate-bad-bot-blocker/.dev-tools/centos7.template
/### Version Information #/x
.t.
.,/### Version Information ##/-d
#,p
#,p used to print output replaced with w below to write
w /home/travis/build/mitchellkrogza/apache-ultimate-bad-bot-blocker/.dev-tools/centos7.template
q
IN
rm ${inputdbA}

# ************************************
# GOOD USER AGENTS - Create and Insert
# ************************************

printf '%s\n' "${start1}" >> ${tmpapache1}
while IFS= read -r LINE
do
printf '%s"%s%s%s" %s\n' "BrowserMatchNoCase " "^(.*?)(\b" "${LINE}" "\b)(.*)$" "${action1}" >> ${tmpapache1}
done < ${input}
printf '%s\n' "${end1}"  >> ${tmpapache1}
mv ${tmpapache1} ${inputdb1}
ed -s ${inputdb1}<<\IN
1,/# START GOOD BOTS ### DO NOT EDIT THIS LINE AT ALL ###/d
/# END GOOD BOTS ### DO NOT EDIT THIS LINE AT ALL ###/,$d
,d
.r /home/travis/build/mitchellkrogza/apache-ultimate-bad-bot-blocker/.dev-tools/centos7.template
/# START GOOD BOTS ### DO NOT EDIT THIS LINE AT ALL ###/x
.t.
.,/# END GOOD BOTS ### DO NOT EDIT THIS LINE AT ALL ###/-d
#,p
#,p used to print output replaced with w below to write
w /home/travis/build/mitchellkrogza/apache-ultimate-bad-bot-blocker/.dev-tools/centos7.template
q
IN
rm ${inputdb1}

# ********************************
# ALLOWED BOTS - Create and Insert
# ********************************

printf '%s\n' "${start2}" >> ${tmpapache2}
while IFS= read -r LINE
do
printf '%s"%s%s%s" %s\n' "BrowserMatchNoCase " "^(.*?)(\b" "${LINE}" "\b)(.*)$" "${action1}" >> ${tmpapache2}
done < ${input2}
printf '%s\n' "${end2}"  >> ${tmpapache2}
mv ${tmpapache2} ${inputdb2}
ed -s ${inputdb2}<<\IN
1,/# START ALLOWED BOTS ### DO NOT EDIT THIS LINE AT ALL ###/d
/# END ALLOWED BOTS ### DO NOT EDIT THIS LINE AT ALL ###/,$d
,d
.r /home/travis/build/mitchellkrogza/apache-ultimate-bad-bot-blocker/.dev-tools/centos7.template
/# START ALLOWED BOTS ### DO NOT EDIT THIS LINE AT ALL ###/x
.t.
.,/# END ALLOWED BOTS ### DO NOT EDIT THIS LINE AT ALL ###/-d
w /home/travis/build/mitchellkrogza/apache-ultimate-bad-bot-blocker/.dev-tools/centos7.template
q
IN
rm ${inputdb2}

# ********************************
# LIMITED BOTS - Create and Insert
# ********************************

printf '%s\n' "${start3}" >> ${tmpapache3}
while IFS= read -r LINE
do
printf '%s"%s%s%s" %s\n' "BrowserMatchNoCase " "^(.*?)(\b" "${LINE}" "\b)(.*)$" "${action1}" >> ${tmpapache3}
done < ${input3}
printf '%s\n' "${end3}"  >> ${tmpapache3}
mv ${tmpapache3} ${inputdb3}
ed -s ${inputdb3}<<\IN
1,/# START LIMITED BOTS ### DO NOT EDIT THIS LINE AT ALL ###/d
/# END LIMITED BOTS ### DO NOT EDIT THIS LINE AT ALL ###/,$d
,d
.r /home/travis/build/mitchellkrogza/apache-ultimate-bad-bot-blocker/.dev-tools/centos7.template
/# START LIMITED BOTS ### DO NOT EDIT THIS LINE AT ALL ###/x
.t.
.,/# END LIMITED BOTS ### DO NOT EDIT THIS LINE AT ALL ###/-d
w /home/travis/build/mitchellkrogza/apache-ultimate-bad-bot-blocker/.dev-tools/centos7.template
q
IN
rm ${inputdb3}

# ****************************
# BAD BOTS - Create and Insert
# ****************************

printf '%s\n' "${start4}" >> ${tmpapache4}
while IFS= read -r LINE
do
printf '%s"%s%s%s" %s\n' "BrowserMatchNoCase " "^(.*?)(\b" "${LINE}" "\b)(.*)$" "${action2}" >> ${tmpapache4}
done < ${input4}
printf '%s\n' "${end4}"  >> ${tmpapache4}
mv ${tmpapache4} ${inputdb4}
ed -s ${inputdb4}<<\IN
1,/# START BAD BOTS ### DO NOT EDIT THIS LINE AT ALL ###/d
/# END BAD BOTS ### DO NOT EDIT THIS LINE AT ALL ###/,$d
,d
.r /home/travis/build/mitchellkrogza/apache-ultimate-bad-bot-blocker/.dev-tools/centos7.template
/# START BAD BOTS ### DO NOT EDIT THIS LINE AT ALL ###/x
.t.
.,/# END BAD BOTS ### DO NOT EDIT THIS LINE AT ALL ###/-d
w /home/travis/build/mitchellkrogza/apache-ultimate-bad-bot-blocker/.dev-tools/centos7.template
q
IN
rm ${inputdb4}

# ********************************
# BAD REFERERS - Create and Insert
# ********************************

printf '%s\n' "${start5}" >> ${tmpapache5}
while IFS= read -r LINE
do
printf '%s\n' "${LINE}" >> ${tmpapache5}
done < ${input5}
printf '%s\n' "${end5}"  >> ${tmpapache5}
mv ${tmpapache5} ${inputdb5}
ed -s ${inputdb5}<<\IN
1,/# START BAD REFERERS ### DO NOT EDIT THIS LINE AT ALL ###/d
/# END BAD REFERERS ### DO NOT EDIT THIS LINE AT ALL ###/,$d
,d
.r /home/travis/build/mitchellkrogza/apache-ultimate-bad-bot-blocker/.dev-tools/centos7.template
/# START BAD REFERERS ### DO NOT EDIT THIS LINE AT ALL ###/x
.t.
.,/# END BAD REFERERS ### DO NOT EDIT THIS LINE AT ALL ###/-d
w /home/travis/build/mitchellkrogza/apache-ultimate-bad-bot-blocker/.dev-tools/centos7.template
q
IN
rm ${inputdb5}

# ************************************
# GOOGLE IP RANGES - Create and Insert
# ************************************

printf '%s\n' "${start6}" >> ${tmpapache6}
while IFS= read -r LINE
do
printf '%s%s\n' "Allow from " "${LINE}" >> ${tmpapache6}
done < ${input6}
printf '%s\n' "${end6}"  >> ${tmpapache6}
mv ${tmpapache6} ${inputdb6}
ed -s ${inputdb6}<<\IN
1,/# START GOOGLE IP RANGES ### DO NOT EDIT THIS LINE AT ALL ###/d
/# END GOOGLE IP RANGES ### DO NOT EDIT THIS LINE AT ALL ###/,$d
,d
.r /home/travis/build/mitchellkrogza/apache-ultimate-bad-bot-blocker/.dev-tools/centos7.template
/# START GOOGLE IP RANGES ### DO NOT EDIT THIS LINE AT ALL ###/x
.t.
.,/# END GOOGLE IP RANGES ### DO NOT EDIT THIS LINE AT ALL ###/-d
w /home/travis/build/mitchellkrogza/apache-ultimate-bad-bot-blocker/.dev-tools/centos7.template
q
IN
rm ${inputdb6}

# **********************************
# BING IP RANGES - Create and Insert
# **********************************

printf '%s\n' "${start7}" >> ${tmpapache7}
while IFS= read -r LINE
do
printf '%s%s\n' "Allow from " "${LINE}" >> ${tmpapache7}
done < ${input7}
printf '%s\n' "${end7}"  >> ${tmpapache7}
mv ${tmpapache7} ${inputdb7}
ed -s ${inputdb7}<<\IN
1,/# START BING IP RANGES ### DO NOT EDIT THIS LINE AT ALL ###/d
/# END BING IP RANGES ### DO NOT EDIT THIS LINE AT ALL ###/,$d
,d
.r /home/travis/build/mitchellkrogza/apache-ultimate-bad-bot-blocker/.dev-tools/centos7.template
/# START BING IP RANGES ### DO NOT EDIT THIS LINE AT ALL ###/x
.t.
.,/# END BING IP RANGES ### DO NOT EDIT THIS LINE AT ALL ###/-d
w /home/travis/build/mitchellkrogza/apache-ultimate-bad-bot-blocker/.dev-tools/centos7.template
q
IN
rm ${inputdb7}

# *********************************************
# Wordpress Theme Detectors - Create and Insert
# *********************************************

printf '%s\n' "${start8}" >> ${tmpapache8}
while IFS= read -r LINE
do
printf '%s%s\n' "deny from " "${LINE}" >> ${tmpapache8}
done < ${input8}
printf '%s\n' "${end8}"  >> ${tmpapache8}
mv ${tmpapache8} ${inputdb8}
ed -s ${inputdb8}<<\IN
1,/# START WP THEME DETECTORS ### DO NOT EDIT THIS LINE AT ALL ###/d
/# END WP THEME DETECTORS ### DO NOT EDIT THIS LINE AT ALL ###/,$d
,d
.r /home/travis/build/mitchellkrogza/apache-ultimate-bad-bot-blocker/.dev-tools/centos7.template
/# START WP THEME DETECTORS ### DO NOT EDIT THIS LINE AT ALL ###/x
.t.
.,/# END WP THEME DETECTORS ### DO NOT EDIT THIS LINE AT ALL ###/-d
w /home/travis/build/mitchellkrogza/apache-ultimate-bad-bot-blocker/.dev-tools/centos7.template
q
IN
rm ${inputdb8}

# *******************************
# Nibbler SEO - Create and Insert
# *******************************

printf '%s\n' "${start9}" >> ${tmpapache9}
while IFS= read -r LINE
do
printf '%s%s\n' "deny from " "${LINE}" >> ${tmpapache9}
done < ${input9}
printf '%s\n' "${end9}"  >> ${tmpapache9}
mv ${tmpapache9} ${inputdb9}
ed -s ${inputdb9}<<\IN
1,/# START NIBBLER ### DO NOT EDIT THIS LINE AT ALL ###/d
/# END NIBBLER ### DO NOT EDIT THIS LINE AT ALL ###/,$d
,d
.r /home/travis/build/mitchellkrogza/apache-ultimate-bad-bot-blocker/.dev-tools/centos7.template
/# START NIBBLER ### DO NOT EDIT THIS LINE AT ALL ###/x
.t.
.,/# END NIBBLER ### DO NOT EDIT THIS LINE AT ALL ###/-d
w /home/travis/build/mitchellkrogza/apache-ultimate-bad-bot-blocker/.dev-tools/centos7.template
q
IN
rm ${inputdb9}

# ****************************************
# CLOUDFLARE IP RANGES - Create and Insert
# ****************************************

printf '%s\n' "${start10}" >> ${tmpapache10}
while IFS= read -r LINE
do
printf '%s%s\n' "Allow from " "${LINE}" >> ${tmpapache10}
done < ${input10}
printf '%s\n' "${end10}"  >> ${tmpapache10}
mv ${tmpapache10} ${inputdb10}
ed -s ${inputdb10}<<\IN
1,/# START CLOUDFLARE IP RANGES ### DO NOT EDIT THIS LINE AT ALL ###/d
/# END CLOUDFLARE IP RANGES ### DO NOT EDIT THIS LINE AT ALL ###/,$d
,d
.r /home/travis/build/mitchellkrogza/apache-ultimate-bad-bot-blocker/.dev-tools/centos7.template
/# START CLOUDFLARE IP RANGES ### DO NOT EDIT THIS LINE AT ALL ###/x
.t.
.,/# END CLOUDFLARE IP RANGES ### DO NOT EDIT THIS LINE AT ALL ###/-d
w /home/travis/build/mitchellkrogza/apache-ultimate-bad-bot-blocker/.dev-tools/centos7.template
q
IN
rm ${inputdb10}

# Copy files to correct folder
# **********************************************
#sudo cp ${apache4} /home/travis/build/mitchellkrogza/apache-ultimate-bad-bot-blocker/_other_distros/CentOS7/custom.d/globalblacklist.conf