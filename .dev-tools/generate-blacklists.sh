#!/bin/bash
# Generator Script for the Apache Ultimate Bad Bot Blocker
# Created by: Mitchell Krog (mitchellkrog@gmail.com)
# Copyright: Mitchell Krog - https://github.com/mitchellkrogza
# Repo Url: https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker

##############################################################################
#        ___                 __                                              #
#       / _ | ___  ___ _____/ /  ___                                         #
#      / __ |/ _ \/ _ `/ __/ _ \/ -_)                                        #
#     /_/ |_/ .__/\_,_/\__/_//_/\__/                                         #
#        __/_/        __   ___       __     ___  __         __               #
#       / _ )___ ____/ /  / _ )___  / /_   / _ )/ /__  ____/ /_____ ____     #
#      / _  / _ `/ _  /  / _  / _ \/ __/  / _  / / _ \/ __/  '_/ -_) __/     #
#     /____/\_,_/\_,_/  /____/\___/\__/  /____/_/\___/\__/_/\_\\__/_/        #
#                                                                            #
##############################################################################

# MIT License

# Copyright (c) 2017 Mitchell Krog - mitchellkrog@gmail.com
# https://github.com/mitchellkrogza

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# ******************
# Set Some Variables
# ******************

yeartag=$(date +"%Y")
monthtag=$(date +"%m")
now="$(date)"
my_git_tag=V3.${yeartag}.${monthtag}.${TRAVIS_BUILD_NUMBER}
bad_referrers=$(wc -l < ${TRAVIS_BUILD_DIR}/_generator_lists/bad-referrers.list)
bad_bots=$(wc -l < ${TRAVIS_BUILD_DIR}/_generator_lists/bad-user-agents.list)
input1=${TRAVIS_BUILD_DIR}/_generator_lists/good-user-agents.list
input2=${TRAVIS_BUILD_DIR}/_generator_lists/allowed-user-agents.list
input3=${TRAVIS_BUILD_DIR}/_generator_lists/limited-user-agents.list
input4=${TRAVIS_BUILD_DIR}/_generator_lists/bad-user-agents.list
input5=${TRAVIS_BUILD_DIR}/.dev-tools/referrers-regex-format.txt
input6=${TRAVIS_BUILD_DIR}/_generator_lists/google-ip-ranges.list
input7=${TRAVIS_BUILD_DIR}/_generator_lists/bing-ip-ranges.list
input8=${TRAVIS_BUILD_DIR}/_generator_lists/wordpress-theme-detectors-apache.list
input9=${TRAVIS_BUILD_DIR}/_generator_lists/nibbler-seo.list
input10=${TRAVIS_BUILD_DIR}/_generator_lists/cloudflare-ip-ranges.list
input11=${TRAVIS_BUILD_DIR}/_generator_lists/bad-user-agents.list
input12=${TRAVIS_BUILD_DIR}/_generator_lists/bad-user-agents-fail2ban-additional.list

# *******************************************************
# Declare temporary database files used during generation
# *******************************************************

inputdbA=/tmp/version-information.db
inputdb1=/tmp/good-user-agents.db
inputdb2=/tmp/allowed-user-agents.db
inputdb3=/tmp/limited-user-agents.db
inputdb4=/tmp/bad-user-agents.db
inputdb5=/tmp/bad-referrers.db
inputdb6=/tmp/google-ip-ranges.db
inputdb7=/tmp/bing-ip-ranges.db
inputdb8=/tmp/wordpress-theme-detectors.db
inputdb9=/tmp/nibbler-seo.db
inputdb10=/tmp/cloudflare-ip-ranges.db


# ******************************************
# Declare Apache template and temp variables
# ******************************************

apache=${TRAVIS_BUILD_DIR}/.dev-tools/apache2.2.template
apache2=${TRAVIS_BUILD_DIR}/.dev-tools/apache2.4.template
apache3=${TRAVIS_BUILD_DIR}/.dev-tools/centos6.template
apache4=${TRAVIS_BUILD_DIR}/.dev-tools/centos7.template
tmpapacheA=tmpapacheA
tmpapacheB=tmpapacheB
tmpapache1=tmpapache1
tmpapache2=tmpapache2
tmpapache3=tmpapache3
tmpapache4=tmpapache4
tmpapache5=tmpapache5
tmpapache6=tmpapache6
tmpapache7=tmpapache7
tmpapache8=tmpapache8
tmpapache9=tmpapache9
tmpapache10=tmpapache10

# ***********************************************
# Sort lists alphabetically and remove duplicates
# ***********************************************

sort -u ${input1} -o ${input1}
sort -u ${input2} -o ${input2}
sort -u ${input3} -o ${input3}
sort -u ${input4} -o ${input4}
sort -u ${input5} -o ${input5}
sort -u ${input6} -o ${input6}
sort -u ${input7} -o ${input7}
sort -u ${input8} -o ${input8}
sort -u ${input9} -o ${input9}
sort -u ${input10} -o ${input10}
sort -u ${input12} -o ${input12}

# ***************************************************************
# Start and End Strings to Search for to do inserts into template
# ***************************************************************

start1="# START GOOD BOTS ### DO NOT EDIT THIS LINE AT ALL ###"
end1="# END GOOD BOTS ### DO NOT EDIT THIS LINE AT ALL ###"
start2="# START ALLOWED BOTS ### DO NOT EDIT THIS LINE AT ALL ###"
end2="# END ALLOWED BOTS ### DO NOT EDIT THIS LINE AT ALL ###"
start3="# START LIMITED BOTS ### DO NOT EDIT THIS LINE AT ALL ###"
end3="# END LIMITED BOTS ### DO NOT EDIT THIS LINE AT ALL ###"
start4="# START BAD BOTS ### DO NOT EDIT THIS LINE AT ALL ###"
end4="# END BAD BOTS ### DO NOT EDIT THIS LINE AT ALL ###"
start5="# START BAD REFERERS ### DO NOT EDIT THIS LINE AT ALL ###"
end5="# END BAD REFERERS ### DO NOT EDIT THIS LINE AT ALL ###"
start6="# START GOOGLE IP RANGES ### DO NOT EDIT THIS LINE AT ALL ###"
end6="# END GOOGLE IP RANGES ### DO NOT EDIT THIS LINE AT ALL ###"
start7="# START BING IP RANGES ### DO NOT EDIT THIS LINE AT ALL ###"
end7="# END BING IP RANGES ### DO NOT EDIT THIS LINE AT ALL ###"
start8="# START WP THEME DETECTORS ### DO NOT EDIT THIS LINE AT ALL ###"
end8="# END WP THEME DETECTORS ### DO NOT EDIT THIS LINE AT ALL ###"
start9="# START NIBBLER ### DO NOT EDIT THIS LINE AT ALL ###"
end9="# END NIBBLER ### DO NOT EDIT THIS LINE AT ALL ###"
start10="# START CLOUDFLARE IP RANGES ### DO NOT EDIT THIS LINE AT ALL ###"
end10="# END CLOUDFLARE IP RANGES ### DO NOT EDIT THIS LINE AT ALL ###"
startmarker="### Version Information #"
endmarker="### Version Information ##"

# ************************************
# Set Our Actions our Blocker Performs
# ************************************

action1="good_bot"
action2="bad_bot"
action3="spam_ref"
action4="good_ref"

# *****************************************************************************************************************
# *****************************************************************************************************************
# *****************************************************************************************************************
# *****************************************************************************************************************
# *****************************************************************************************************************
# *****************************************************************************************************************

# *************************************************
# GENERATE THE APACHE 2.2 VERSION OF THE BLOCKER
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
.r /home/travis/build/mitchellkrogza/apache-ultimate-bad-bot-blocker/.dev-tools/apache2.2.template
/### Version Information #/x
.t.
.,/### Version Information ##/-d
#,p
#,p used to print output replaced with w below to write
w /home/travis/build/mitchellkrogza/apache-ultimate-bad-bot-blocker/.dev-tools/apache2.2.template
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
.r /home/travis/build/mitchellkrogza/apache-ultimate-bad-bot-blocker/.dev-tools/apache2.2.template
/# START GOOD BOTS ### DO NOT EDIT THIS LINE AT ALL ###/x
.t.
.,/# END GOOD BOTS ### DO NOT EDIT THIS LINE AT ALL ###/-d
#,p
#,p used to print output replaced with w below to write
w /home/travis/build/mitchellkrogza/apache-ultimate-bad-bot-blocker/.dev-tools/apache2.2.template
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
.r /home/travis/build/mitchellkrogza/apache-ultimate-bad-bot-blocker/.dev-tools/apache2.2.template
/# START ALLOWED BOTS ### DO NOT EDIT THIS LINE AT ALL ###/x
.t.
.,/# END ALLOWED BOTS ### DO NOT EDIT THIS LINE AT ALL ###/-d
w /home/travis/build/mitchellkrogza/apache-ultimate-bad-bot-blocker/.dev-tools/apache2.2.template
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
.r /home/travis/build/mitchellkrogza/apache-ultimate-bad-bot-blocker/.dev-tools/apache2.2.template
/# START LIMITED BOTS ### DO NOT EDIT THIS LINE AT ALL ###/x
.t.
.,/# END LIMITED BOTS ### DO NOT EDIT THIS LINE AT ALL ###/-d
w /home/travis/build/mitchellkrogza/apache-ultimate-bad-bot-blocker/.dev-tools/apache2.2.template
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
.r /home/travis/build/mitchellkrogza/apache-ultimate-bad-bot-blocker/.dev-tools/apache2.2.template
/# START BAD BOTS ### DO NOT EDIT THIS LINE AT ALL ###/x
.t.
.,/# END BAD BOTS ### DO NOT EDIT THIS LINE AT ALL ###/-d
w /home/travis/build/mitchellkrogza/apache-ultimate-bad-bot-blocker/.dev-tools/apache2.2.template
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
.r /home/travis/build/mitchellkrogza/apache-ultimate-bad-bot-blocker/.dev-tools/apache2.2.template
/# START BAD REFERERS ### DO NOT EDIT THIS LINE AT ALL ###/x
.t.
.,/# END BAD REFERERS ### DO NOT EDIT THIS LINE AT ALL ###/-d
w /home/travis/build/mitchellkrogza/apache-ultimate-bad-bot-blocker/.dev-tools/apache2.2.template
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
.r /home/travis/build/mitchellkrogza/apache-ultimate-bad-bot-blocker/.dev-tools/apache2.2.template
/# START GOOGLE IP RANGES ### DO NOT EDIT THIS LINE AT ALL ###/x
.t.
.,/# END GOOGLE IP RANGES ### DO NOT EDIT THIS LINE AT ALL ###/-d
w /home/travis/build/mitchellkrogza/apache-ultimate-bad-bot-blocker/.dev-tools/apache2.2.template
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
.r /home/travis/build/mitchellkrogza/apache-ultimate-bad-bot-blocker/.dev-tools/apache2.2.template
/# START BING IP RANGES ### DO NOT EDIT THIS LINE AT ALL ###/x
.t.
.,/# END BING IP RANGES ### DO NOT EDIT THIS LINE AT ALL ###/-d
w /home/travis/build/mitchellkrogza/apache-ultimate-bad-bot-blocker/.dev-tools/apache2.2.template
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
.r /home/travis/build/mitchellkrogza/apache-ultimate-bad-bot-blocker/.dev-tools/apache2.2.template
/# START WP THEME DETECTORS ### DO NOT EDIT THIS LINE AT ALL ###/x
.t.
.,/# END WP THEME DETECTORS ### DO NOT EDIT THIS LINE AT ALL ###/-d
w /home/travis/build/mitchellkrogza/apache-ultimate-bad-bot-blocker/.dev-tools/apache2.2.template
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
.r /home/travis/build/mitchellkrogza/apache-ultimate-bad-bot-blocker/.dev-tools/apache2.2.template
/# START NIBBLER ### DO NOT EDIT THIS LINE AT ALL ###/x
.t.
.,/# END NIBBLER ### DO NOT EDIT THIS LINE AT ALL ###/-d
w /home/travis/build/mitchellkrogza/apache-ultimate-bad-bot-blocker/.dev-tools/apache2.2.template
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
.r /home/travis/build/mitchellkrogza/apache-ultimate-bad-bot-blocker/.dev-tools/apache2.2.template
/# START CLOUDFLARE IP RANGES ### DO NOT EDIT THIS LINE AT ALL ###/x
.t.
.,/# END CLOUDFLARE IP RANGES ### DO NOT EDIT THIS LINE AT ALL ###/-d
w /home/travis/build/mitchellkrogza/apache-ultimate-bad-bot-blocker/.dev-tools/apache2.2.template
q
IN
rm ${inputdb10}

# Copy files to correct folders
# **********************************************
sudo cp ${apache} /home/travis/build/mitchellkrogza/apache-ultimate-bad-bot-blocker/Apache_2.2/custom.d/globalblacklist.conf

# *****************************************************************************************************************
# *****************************************************************************************************************
# *****************************************************************************************************************
# *****************************************************************************************************************
# *****************************************************************************************************************
# *****************************************************************************************************************

# *************************************************
# GENERATE THE APACHE 2.4 VERSION OF THE BLOCKER
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
.r /home/travis/build/mitchellkrogza/apache-ultimate-bad-bot-blocker/.dev-tools/apache2.4.template
/### Version Information #/x
.t.
.,/### Version Information ##/-d
#,p
#,p used to print output replaced with w below to write
w /home/travis/build/mitchellkrogza/apache-ultimate-bad-bot-blocker/.dev-tools/apache2.4.template
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
.r /home/travis/build/mitchellkrogza/apache-ultimate-bad-bot-blocker/.dev-tools/apache2.4.template
/# START GOOD BOTS ### DO NOT EDIT THIS LINE AT ALL ###/x
.t.
.,/# END GOOD BOTS ### DO NOT EDIT THIS LINE AT ALL ###/-d
#,p
#,p used to print output replaced with w below to write
w /home/travis/build/mitchellkrogza/apache-ultimate-bad-bot-blocker/.dev-tools/apache2.4.template
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
.r /home/travis/build/mitchellkrogza/apache-ultimate-bad-bot-blocker/.dev-tools/apache2.4.template
/# START ALLOWED BOTS ### DO NOT EDIT THIS LINE AT ALL ###/x
.t.
.,/# END ALLOWED BOTS ### DO NOT EDIT THIS LINE AT ALL ###/-d
w /home/travis/build/mitchellkrogza/apache-ultimate-bad-bot-blocker/.dev-tools/apache2.4.template
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
.r /home/travis/build/mitchellkrogza/apache-ultimate-bad-bot-blocker/.dev-tools/apache2.4.template
/# START LIMITED BOTS ### DO NOT EDIT THIS LINE AT ALL ###/x
.t.
.,/# END LIMITED BOTS ### DO NOT EDIT THIS LINE AT ALL ###/-d
w /home/travis/build/mitchellkrogza/apache-ultimate-bad-bot-blocker/.dev-tools/apache2.4.template
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
.r /home/travis/build/mitchellkrogza/apache-ultimate-bad-bot-blocker/.dev-tools/apache2.4.template
/# START BAD BOTS ### DO NOT EDIT THIS LINE AT ALL ###/x
.t.
.,/# END BAD BOTS ### DO NOT EDIT THIS LINE AT ALL ###/-d
w /home/travis/build/mitchellkrogza/apache-ultimate-bad-bot-blocker/.dev-tools/apache2.4.template
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
.r /home/travis/build/mitchellkrogza/apache-ultimate-bad-bot-blocker/.dev-tools/apache2.4.template
/# START BAD REFERERS ### DO NOT EDIT THIS LINE AT ALL ###/x
.t.
.,/# END BAD REFERERS ### DO NOT EDIT THIS LINE AT ALL ###/-d
w /home/travis/build/mitchellkrogza/apache-ultimate-bad-bot-blocker/.dev-tools/apache2.4.template
q
IN
rm ${inputdb5}

# ************************************
# GOOGLE IP RANGES - Create and Insert
# ************************************

printf '%s\n' "${start6}" >> ${tmpapache6}
while IFS= read -r LINE
do
printf '\t%s%s\n' "Require ip " "${LINE}" >> ${tmpapache6}
done < ${input6}
printf '%s\n' "${end6}"  >> ${tmpapache6}
mv ${tmpapache6} ${inputdb6}
ed -s ${inputdb6}<<\IN
1,/# START GOOGLE IP RANGES ### DO NOT EDIT THIS LINE AT ALL ###/d
/# END GOOGLE IP RANGES ### DO NOT EDIT THIS LINE AT ALL ###/,$d
,d
.r /home/travis/build/mitchellkrogza/apache-ultimate-bad-bot-blocker/.dev-tools/apache2.4.template
/# START GOOGLE IP RANGES ### DO NOT EDIT THIS LINE AT ALL ###/x
.t.
.,/# END GOOGLE IP RANGES ### DO NOT EDIT THIS LINE AT ALL ###/-d
w /home/travis/build/mitchellkrogza/apache-ultimate-bad-bot-blocker/.dev-tools/apache2.4.template
q
IN
rm ${inputdb6}

# **********************************
# BING IP RANGES - Create and Insert
# **********************************

printf '%s\n' "${start7}" >> ${tmpapache7}
while IFS= read -r LINE
do
printf '\t%s%s\n' "Require ip " "${LINE}" >> ${tmpapache7}
done < ${input7}
printf '%s\n' "${end7}"  >> ${tmpapache7}
mv ${tmpapache7} ${inputdb7}
ed -s ${inputdb7}<<\IN
1,/# START BING IP RANGES ### DO NOT EDIT THIS LINE AT ALL ###/d
/# END BING IP RANGES ### DO NOT EDIT THIS LINE AT ALL ###/,$d
,d
.r /home/travis/build/mitchellkrogza/apache-ultimate-bad-bot-blocker/.dev-tools/apache2.4.template
/# START BING IP RANGES ### DO NOT EDIT THIS LINE AT ALL ###/x
.t.
.,/# END BING IP RANGES ### DO NOT EDIT THIS LINE AT ALL ###/-d
w /home/travis/build/mitchellkrogza/apache-ultimate-bad-bot-blocker/.dev-tools/apache2.4.template
q
IN
rm ${inputdb7}

# *********************************************
# Wordpress Theme Detectors - Create and Insert
# *********************************************

printf '%s\n' "${start8}" >> ${tmpapache8}
while IFS= read -r LINE
do
printf '\t%s%s\n' "Require not ip " "${LINE}" >> ${tmpapache8}
done < ${input8}
printf '%s\n' "${end8}"  >> ${tmpapache8}
mv ${tmpapache8} ${inputdb8}
ed -s ${inputdb8}<<\IN
1,/# START WP THEME DETECTORS ### DO NOT EDIT THIS LINE AT ALL ###/d
/# END WP THEME DETECTORS ### DO NOT EDIT THIS LINE AT ALL ###/,$d
,d
.r /home/travis/build/mitchellkrogza/apache-ultimate-bad-bot-blocker/.dev-tools/apache2.4.template
/# START WP THEME DETECTORS ### DO NOT EDIT THIS LINE AT ALL ###/x
.t.
.,/# END WP THEME DETECTORS ### DO NOT EDIT THIS LINE AT ALL ###/-d
w /home/travis/build/mitchellkrogza/apache-ultimate-bad-bot-blocker/.dev-tools/apache2.4.template
q
IN
rm ${inputdb8}

# *******************************
# Nibbler SEO - Create and Insert
# *******************************

printf '%s\n' "${start9}" >> ${tmpapache9}
while IFS= read -r LINE
do
printf '\t%s%s\n' "Require not ip " "${LINE}" >> ${tmpapache9}
done < ${input9}
printf '%s\n' "${end9}"  >> ${tmpapache9}
mv ${tmpapache9} ${inputdb9}
ed -s ${inputdb9}<<\IN
1,/# START NIBBLER ### DO NOT EDIT THIS LINE AT ALL ###/d
/# END NIBBLER ### DO NOT EDIT THIS LINE AT ALL ###/,$d
,d
.r /home/travis/build/mitchellkrogza/apache-ultimate-bad-bot-blocker/.dev-tools/apache2.4.template
/# START NIBBLER ### DO NOT EDIT THIS LINE AT ALL ###/x
.t.
.,/# END NIBBLER ### DO NOT EDIT THIS LINE AT ALL ###/-d
w /home/travis/build/mitchellkrogza/apache-ultimate-bad-bot-blocker/.dev-tools/apache2.4.template
q
IN
rm ${inputdb9}

# ****************************************
# CLOUDFLARE IP RANGES - Create and Insert
# ****************************************

printf '%s\n' "${start10}" >> ${tmpapache10}
while IFS= read -r LINE
do
printf '\t%s%s\n' "Require ip " "${LINE}" >> ${tmpapache10}
done < ${input10}
printf '%s\n' "${end10}"  >> ${tmpapache10}
mv ${tmpapache10} ${inputdb10}
ed -s ${inputdb10}<<\IN
1,/# START CLOUDFLARE IP RANGES ### DO NOT EDIT THIS LINE AT ALL ###/d
/# END CLOUDFLARE IP RANGES ### DO NOT EDIT THIS LINE AT ALL ###/,$d
,d
.r /home/travis/build/mitchellkrogza/apache-ultimate-bad-bot-blocker/.dev-tools/apache2.4.template
/# START CLOUDFLARE IP RANGES ### DO NOT EDIT THIS LINE AT ALL ###/x
.t.
.,/# END CLOUDFLARE IP RANGES ### DO NOT EDIT THIS LINE AT ALL ###/-d
w /home/travis/build/mitchellkrogza/apache-ultimate-bad-bot-blocker/.dev-tools/apache2.4.template
q
IN
rm ${inputdb10}

# Copy file to correct folder
# **********************************************
sudo cp ${apache2} /home/travis/build/mitchellkrogza/apache-ultimate-bad-bot-blocker/Apache_2.4/custom.d/globalblacklist.conf

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

# **********************
# Exit With Error Number
# **********************

exit ${?}