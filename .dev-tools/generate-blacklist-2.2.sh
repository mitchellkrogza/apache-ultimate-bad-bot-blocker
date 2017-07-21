#!/bin/bash
# Generator Script for the Apache Ultimate Bad Bot Blocker
# Created by: Mitchell Krog (mitchellkrog@gmail.com)
# Copyright: Mitchell Krog - https://github.com/mitchellkrogza
# Repo Url: https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker

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

YEAR=$(date +"%Y")
MONTH=$(date +"%m")
MY_GIT_TAG=V3.$YEAR.$MONTH.$TRAVIS_BUILD_NUMBER
BAD_REFERRERS=$(wc -l < $TRAVIS_BUILD_DIR/_generator_lists/bad-referrers.list)
BAD_BOTS=$(wc -l < $TRAVIS_BUILD_DIR/_generator_lists/bad-user-agents.list)
_now="$(date)"


_input1=$TRAVIS_BUILD_DIR/_generator_lists/good-user-agents.list
_input2=$TRAVIS_BUILD_DIR/_generator_lists/allowed-user-agents.list
_input3=$TRAVIS_BUILD_DIR/_generator_lists/limited-user-agents.list
_input4=$TRAVIS_BUILD_DIR/_generator_lists/bad-user-agents.list
_input5=$TRAVIS_BUILD_DIR/.dev-tools/referrers-regex-format.txt
_input6=$TRAVIS_BUILD_DIR/_generator_lists/google-ip-ranges.list
_input7=$TRAVIS_BUILD_DIR/_generator_lists/bing-ip-ranges.list
_input8=$TRAVIS_BUILD_DIR/_generator_lists/wordpress-theme-detectors-apache.list
_input9=$TRAVIS_BUILD_DIR/_generator_lists/nibbler-seo.list
_input10=$TRAVIS_BUILD_DIR/_generator_lists/cloudflare-ip-ranges.list
_input11=$TRAVIS_BUILD_DIR/_generator_lists/bad-user-agents.list

# *******************************************************
# Declare temporary database files used during generation
# *******************************************************

_inputdbA=/tmp/version-information.db
_inputdb1=/tmp/good-user-agents.db
_inputdb2=/tmp/allowed-user-agents.db
_inputdb3=/tmp/limited-user-agents.db
_inputdb4=/tmp/bad-user-agents.db
_inputdb5=/tmp/bad-referrers.db
_inputdb6=/tmp/google-ip-ranges.db
_inputdb7=/tmp/bing-ip-ranges.db
_inputdb8=/tmp/wordpress-theme-detectors.db
_inputdb9=/tmp/nibbler-seo.db
_inputdb10=/tmp/cloudflare-ip-ranges.db


# Declare Apache template and temp variables
_apache=$TRAVIS_BUILD_DIR/.dev-tools/apache2.2.template
_apache2=$TRAVIS_BUILD_DIR/.dev-tools/apache2.4.template
_apache3=$TRAVIS_BUILD_DIR/.dev-tools/centos6.template
_apache4=$TRAVIS_BUILD_DIR/.dev-tools/centos7.template
_tmpapacheA=_tmpapacheA
_tmpapacheB=_tmpapacheB
_tmpapache1=_tmpapache1
_tmpapache2=_tmpapache2
_tmpapache3=_tmpapache3
_tmpapache4=_tmpapache4
_tmpapache5=_tmpapache5
_tmpapache6=_tmpapache6
_tmpapache7=_tmpapache7
_tmpapache8=_tmpapache8
_tmpapache9=_tmpapache9
_tmpapache10=_tmpapache10

# Sort lists alphabetically and remove duplicates
sort -u $_input1 -o $_input1
sort -u $_input2 -o $_input2
sort -u $_input3 -o $_input3
sort -u $_input4 -o $_input4
sort -u $_input5 -o $_input5
sort -u $_input6 -o $_input6
sort -u $_input7 -o $_input7
sort -u $_input8 -o $_input8
sort -u $_input9 -o $_input9
sort -u $_input10 -o $_input10

# Start and End Strings to Search for to do inserts into template
_start1="# START GOOD BOTS ### DO NOT EDIT THIS LINE AT ALL ###"
_end1="# END GOOD BOTS ### DO NOT EDIT THIS LINE AT ALL ###"
_start2="# START ALLOWED BOTS ### DO NOT EDIT THIS LINE AT ALL ###"
_end2="# END ALLOWED BOTS ### DO NOT EDIT THIS LINE AT ALL ###"
_start3="# START LIMITED BOTS ### DO NOT EDIT THIS LINE AT ALL ###"
_end3="# END LIMITED BOTS ### DO NOT EDIT THIS LINE AT ALL ###"
_start4="# START BAD BOTS ### DO NOT EDIT THIS LINE AT ALL ###"
_end4="# END BAD BOTS ### DO NOT EDIT THIS LINE AT ALL ###"
_start5="# START BAD REFERERS ### DO NOT EDIT THIS LINE AT ALL ###"
_end5="# END BAD REFERERS ### DO NOT EDIT THIS LINE AT ALL ###"
_start6="# START GOOGLE IP RANGES ### DO NOT EDIT THIS LINE AT ALL ###"
_end6="# END GOOGLE IP RANGES ### DO NOT EDIT THIS LINE AT ALL ###"
_start7="# START BING IP RANGES ### DO NOT EDIT THIS LINE AT ALL ###"
_end7="# END BING IP RANGES ### DO NOT EDIT THIS LINE AT ALL ###"
_start8="# START WP THEME DETECTORS ### DO NOT EDIT THIS LINE AT ALL ###"
_end8="# END WP THEME DETECTORS ### DO NOT EDIT THIS LINE AT ALL ###"
_start9="# START NIBBLER ### DO NOT EDIT THIS LINE AT ALL ###"
_end9="# END NIBBLER ### DO NOT EDIT THIS LINE AT ALL ###"
_start10="# START CLOUDFLARE IP RANGES ### DO NOT EDIT THIS LINE AT ALL ###"
_end10="# END CLOUDFLARE IP RANGES ### DO NOT EDIT THIS LINE AT ALL ###"
_startmarker="### Version Information #"
_endmarker="### Version Information ##"

_action1="good_bot"
_action2="bad_bot"
_action3="spam_ref"
_action4="good_ref"

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

printf '%s\n%s\n%s%s\n%s%s\n%s%s\n%s%s\n%s\n%s\n' "$_startmarker" "###################################################" "### Version: " "$MY_GIT_TAG" "### Updated: " "$_now" "### Bad Referrer Count: " "$BAD_REFERRERS" "### Bad Bot Count: " "$BAD_BOTS" "###################################################" "$_endmarker" >> "$_tmpapacheA"
mv $_tmpapacheA $_inputdbA
ed -s $_inputdbA<<\IN
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
rm $_inputdbA

# ************************************
# GOOD USER AGENTS - Create and Insert
# ************************************

printf '%s\n' "$_start1" >> "$_tmpapache1"
while IFS= read -r LINE
do
printf '%s"%s%s%s" %s\n' "BrowserMatchNoCase " "^(.*?)(\b" "${LINE}" "\b)(.*)$" "$_action1" >> "$_tmpapache1"
done < $_input1
printf '%s\n' "$_end1"  >> "$_tmpapache1"
mv $_tmpapache1 $_inputdb1
ed -s $_inputdb1<<\IN
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
rm $_inputdb1

# ********************************
# ALLOWED BOTS - Create and Insert
# ********************************

printf '%s\n' "$_start2" >> "$_tmpapache2"
while IFS= read -r LINE
do
printf '%s"%s%s%s" %s\n' "BrowserMatchNoCase " "^(.*?)(\b" "${LINE}" "\b)(.*)$" "$_action1" >> "$_tmpapache2"
done < $_input2
printf '%s\n' "$_end2"  >> "$_tmpapache2"
mv $_tmpapache2 $_inputdb2
ed -s $_inputdb2<<\IN
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
rm $_inputdb2

# ********************************
# LIMITED BOTS - Create and Insert
# ********************************

printf '%s\n' "$_start3" >> "$_tmpapache3"
while IFS= read -r LINE
do
printf '%s"%s%s%s" %s\n' "BrowserMatchNoCase " "^(.*?)(\b" "${LINE}" "\b)(.*)$" "$_action1" >> "$_tmpapache3"
done < $_input3
printf '%s\n' "$_end3"  >> "$_tmpapache3"
mv $_tmpapache3 $_inputdb3
ed -s $_inputdb3<<\IN
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
rm $_inputdb3

# ****************************
# BAD BOTS - Create and Insert
# ****************************

printf '%s\n' "$_start4" >> "$_tmpapache4"
while IFS= read -r LINE
do
printf '%s"%s%s%s" %s\n' "BrowserMatchNoCase " "^(.*?)(\b" "${LINE}" "\b)(.*)$" "$_action2" >> "$_tmpapache4"
done < $_input4
printf '%s\n' "$_end4"  >> "$_tmpapache4"
mv $_tmpapache4 $_inputdb4
ed -s $_inputdb4<<\IN
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
rm $_inputdb4

# ********************************
# BAD REFERERS - Create and Insert
# ********************************

printf '%s\n' "$_start5" >> "$_tmpapache5"
while IFS= read -r LINE
do
printf '%s\n' "${LINE}" >> "$_tmpapache5"
done < $_input5
printf '%s\n' "$_end5"  >> "$_tmpapache5"
mv $_tmpapache5 $_inputdb5
ed -s $_inputdb5<<\IN
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
rm $_inputdb5

# ************************************
# GOOGLE IP RANGES - Create and Insert
# ************************************

printf '%s\n' "$_start6" >> "$_tmpapache6"
while IFS= read -r LINE
do
printf '%s%s\n' "Allow from " "${LINE}" >> "$_tmpapache6"
done < $_input6
printf '%s\n' "$_end6"  >> "$_tmpapache6"
mv $_tmpapache6 $_inputdb6
ed -s $_inputdb6<<\IN
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
rm $_inputdb6

# **********************************
# BING IP RANGES - Create and Insert
# **********************************

printf '%s\n' "$_start7" >> "$_tmpapache7"
while IFS= read -r LINE
do
printf '%s%s\n' "Allow from " "${LINE}" >> "$_tmpapache7"
done < $_input7
printf '%s\n' "$_end7"  >> "$_tmpapache7"
mv $_tmpapache7 $_inputdb7
ed -s $_inputdb7<<\IN
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
rm $_inputdb7

# *********************************************
# Wordpress Theme Detectors - Create and Insert
# *********************************************

printf '%s\n' "$_start8" >> "$_tmpapache8"
while IFS= read -r LINE
do
printf '%s%s\n' "deny from " "${LINE}" >> "$_tmpapache8"
done < $_input8
printf '%s\n' "$_end8"  >> "$_tmpapache8"
mv $_tmpapache8 $_inputdb8
ed -s $_inputdb8<<\IN
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
rm $_inputdb8

# *******************************
# Nibbler SEO - Create and Insert
# *******************************

printf '%s\n' "$_start9" >> "$_tmpapache9"
while IFS= read -r LINE
do
printf '%s%s\n' "deny from " "${LINE}" >> "$_tmpapache9"
done < $_input9
printf '%s\n' "$_end9"  >> "$_tmpapache9"
mv $_tmpapache9 $_inputdb9
ed -s $_inputdb9<<\IN
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
rm $_inputdb9

# ****************************************
# CLOUDFLARE IP RANGES - Create and Insert
# ****************************************

printf '%s\n' "$_start10" >> "$_tmpapache10"
while IFS= read -r LINE
do
printf '%s%s\n' "Allow from " "${LINE}" >> "$_tmpapache10"
done < $_input10
printf '%s\n' "$_end10"  >> "$_tmpapache10"
mv $_tmpapache10 $_inputdb10
ed -s $_inputdb10<<\IN
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
rm $_inputdb10

# Copy files to correct folders
# **********************************************
sudo cp $_apache /home/travis/build/mitchellkrogza/apache-ultimate-bad-bot-blocker/Apache_2.2/custom.d/globalblacklist.conf

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

printf '%s\n%s\n%s%s\n%s%s\n%s%s\n%s%s\n%s\n%s\n' "$_startmarker" "###################################################" "### Version: " "$MY_GIT_TAG" "### Updated: " "$_now" "### Bad Referrer Count: " "$BAD_REFERRERS" "### Bad Bot Count: " "$BAD_BOTS" "###################################################" "$_endmarker" >> "$_tmpapacheA"
mv $_tmpapacheA $_inputdbA
ed -s $_inputdbA<<\IN
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
rm $_inputdbA

# ************************************
# GOOD USER AGENTS - Create and Insert
# ************************************

printf '%s\n' "$_start1" >> "$_tmpapache1"
while IFS= read -r LINE
do
printf '%s"%s%s%s" %s\n' "BrowserMatchNoCase " "^(.*?)(\b" "${LINE}" "\b)(.*)$" "$_action1" >> "$_tmpapache1"
done < $_input1
printf '%s\n' "$_end1"  >> "$_tmpapache1"
mv $_tmpapache1 $_inputdb1
ed -s $_inputdb1<<\IN
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
rm $_inputdb1

# ********************************
# ALLOWED BOTS - Create and Insert
# ********************************

printf '%s\n' "$_start2" >> "$_tmpapache2"
while IFS= read -r LINE
do
printf '%s"%s%s%s" %s\n' "BrowserMatchNoCase " "^(.*?)(\b" "${LINE}" "\b)(.*)$" "$_action1" >> "$_tmpapache2"
done < $_input2
printf '%s\n' "$_end2"  >> "$_tmpapache2"
mv $_tmpapache2 $_inputdb2
ed -s $_inputdb2<<\IN
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
rm $_inputdb2

# ********************************
# LIMITED BOTS - Create and Insert
# ********************************

printf '%s\n' "$_start3" >> "$_tmpapache3"
while IFS= read -r LINE
do
printf '%s"%s%s%s" %s\n' "BrowserMatchNoCase " "^(.*?)(\b" "${LINE}" "\b)(.*)$" "$_action1" >> "$_tmpapache3"
done < $_input3
printf '%s\n' "$_end3"  >> "$_tmpapache3"
mv $_tmpapache3 $_inputdb3
ed -s $_inputdb3<<\IN
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
rm $_inputdb3

# ****************************
# BAD BOTS - Create and Insert
# ****************************

printf '%s\n' "$_start4" >> "$_tmpapache4"
while IFS= read -r LINE
do
printf '%s"%s%s%s" %s\n' "BrowserMatchNoCase " "^(.*?)(\b" "${LINE}" "\b)(.*)$" "$_action2" >> "$_tmpapache4"
done < $_input4
printf '%s\n' "$_end4"  >> "$_tmpapache4"
mv $_tmpapache4 $_inputdb4
ed -s $_inputdb4<<\IN
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
rm $_inputdb4

# ********************************
# BAD REFERERS - Create and Insert
# ********************************

printf '%s\n' "$_start5" >> "$_tmpapache5"
while IFS= read -r LINE
do
printf '%s\n' "${LINE}" >> "$_tmpapache5"
done < $_input5
printf '%s\n' "$_end5"  >> "$_tmpapache5"
mv $_tmpapache5 $_inputdb5
ed -s $_inputdb5<<\IN
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
rm $_inputdb5

# ************************************
# GOOGLE IP RANGES - Create and Insert
# ************************************

printf '%s\n' "$_start6" >> "$_tmpapache6"
while IFS= read -r LINE
do
printf '%s%s\n' "Require ip " "${LINE}" >> "$_tmpapache6"
done < $_input6
printf '%s\n' "$_end6"  >> "$_tmpapache6"
mv $_tmpapache6 $_inputdb6
ed -s $_inputdb6<<\IN
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
rm $_inputdb6

# **********************************
# BING IP RANGES - Create and Insert
# **********************************

printf '%s\n' "$_start7" >> "$_tmpapache7"
while IFS= read -r LINE
do
printf '%s%s\n' "Require ip " "${LINE}" >> "$_tmpapache7"
done < $_input7
printf '%s\n' "$_end7"  >> "$_tmpapache7"
mv $_tmpapache7 $_inputdb7
ed -s $_inputdb7<<\IN
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
rm $_inputdb7

# *********************************************
# Wordpress Theme Detectors - Create and Insert
# *********************************************

printf '%s\n' "$_start8" >> "$_tmpapache8"
while IFS= read -r LINE
do
printf '%s%s\n' "Require not ip " "${LINE}" >> "$_tmpapache8"
done < $_input8
printf '%s\n' "$_end8"  >> "$_tmpapache8"
mv $_tmpapache8 $_inputdb8
ed -s $_inputdb8<<\IN
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
rm $_inputdb8

# *******************************
# Nibbler SEO - Create and Insert
# *******************************

printf '%s\n' "$_start9" >> "$_tmpapache9"
while IFS= read -r LINE
do
printf '%s%s\n' "Require not ip " "${LINE}" >> "$_tmpapache9"
done < $_input9
printf '%s\n' "$_end9"  >> "$_tmpapache9"
mv $_tmpapache9 $_inputdb9
ed -s $_inputdb9<<\IN
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
rm $_inputdb9

# ****************************************
# CLOUDFLARE IP RANGES - Create and Insert
# ****************************************

printf '%s\n' "$_start10" >> "$_tmpapache10"
while IFS= read -r LINE
do
printf '%s%s\n' "Require ip " "${LINE}" >> "$_tmpapache10"
done < $_input10
printf '%s\n' "$_end10"  >> "$_tmpapache10"
mv $_tmpapache10 $_inputdb10
ed -s $_inputdb10<<\IN
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
rm $_inputdb10

# Copy file to correct folder
# **********************************************
sudo cp $_apache2 /home/travis/build/mitchellkrogza/apache-ultimate-bad-bot-blocker/Apache_2.4/custom.d/globalblacklist.conf

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

printf '%s\n%s\n%s%s\n%s%s\n%s%s\n%s%s\n%s\n%s\n' "$_startmarker" "###################################################" "### Version: " "$MY_GIT_TAG" "### Updated: " "$_now" "### Bad Referrer Count: " "$BAD_REFERRERS" "### Bad Bot Count: " "$BAD_BOTS" "###################################################" "$_endmarker" >> "$_tmpapacheA"
mv $_tmpapacheA $_inputdbA
ed -s $_inputdbA<<\IN
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
rm $_inputdbA

# ************************************
# GOOD USER AGENTS - Create and Insert
# ************************************

printf '%s\n' "$_start1" >> "$_tmpapache1"
while IFS= read -r LINE
do
printf '%s"%s%s%s" %s\n' "BrowserMatchNoCase " "^(.*?)(\b" "${LINE}" "\b)(.*)$" "$_action1" >> "$_tmpapache1"
done < $_input1
printf '%s\n' "$_end1"  >> "$_tmpapache1"
mv $_tmpapache1 $_inputdb1
ed -s $_inputdb1<<\IN
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
rm $_inputdb1

# ********************************
# ALLOWED BOTS - Create and Insert
# ********************************

printf '%s\n' "$_start2" >> "$_tmpapache2"
while IFS= read -r LINE
do
printf '%s"%s%s%s" %s\n' "BrowserMatchNoCase " "^(.*?)(\b" "${LINE}" "\b)(.*)$" "$_action1" >> "$_tmpapache2"
done < $_input2
printf '%s\n' "$_end2"  >> "$_tmpapache2"
mv $_tmpapache2 $_inputdb2
ed -s $_inputdb2<<\IN
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
rm $_inputdb2

# ********************************
# LIMITED BOTS - Create and Insert
# ********************************

printf '%s\n' "$_start3" >> "$_tmpapache3"
while IFS= read -r LINE
do
printf '%s"%s%s%s" %s\n' "BrowserMatchNoCase " "^(.*?)(\b" "${LINE}" "\b)(.*)$" "$_action1" >> "$_tmpapache3"
done < $_input3
printf '%s\n' "$_end3"  >> "$_tmpapache3"
mv $_tmpapache3 $_inputdb3
ed -s $_inputdb3<<\IN
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
rm $_inputdb3

# ****************************
# BAD BOTS - Create and Insert
# ****************************

printf '%s\n' "$_start4" >> "$_tmpapache4"
while IFS= read -r LINE
do
printf '%s"%s%s%s" %s\n' "BrowserMatchNoCase " "^(.*?)(\b" "${LINE}" "\b)(.*)$" "$_action2" >> "$_tmpapache4"
done < $_input4
printf '%s\n' "$_end4"  >> "$_tmpapache4"
mv $_tmpapache4 $_inputdb4
ed -s $_inputdb4<<\IN
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
rm $_inputdb4

# ********************************
# BAD REFERERS - Create and Insert
# ********************************

printf '%s\n' "$_start5" >> "$_tmpapache5"
while IFS= read -r LINE
do
printf '%s\n' "${LINE}" >> "$_tmpapache5"
done < $_input5
printf '%s\n' "$_end5"  >> "$_tmpapache5"
mv $_tmpapache5 $_inputdb5
ed -s $_inputdb5<<\IN
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
rm $_inputdb5

# ************************************
# GOOGLE IP RANGES - Create and Insert
# ************************************

printf '%s\n' "$_start6" >> "$_tmpapache6"
while IFS= read -r LINE
do
printf '%s%s\n' "Allow from " "${LINE}" >> "$_tmpapache6"
done < $_input6
printf '%s\n' "$_end6"  >> "$_tmpapache6"
mv $_tmpapache6 $_inputdb6
ed -s $_inputdb6<<\IN
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
rm $_inputdb6

# **********************************
# BING IP RANGES - Create and Insert
# **********************************

printf '%s\n' "$_start7" >> "$_tmpapache7"
while IFS= read -r LINE
do
printf '%s%s\n' "Allow from " "${LINE}" >> "$_tmpapache7"
done < $_input7
printf '%s\n' "$_end7"  >> "$_tmpapache7"
mv $_tmpapache7 $_inputdb7
ed -s $_inputdb7<<\IN
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
rm $_inputdb7

# *********************************************
# Wordpress Theme Detectors - Create and Insert
# *********************************************

printf '%s\n' "$_start8" >> "$_tmpapache8"
while IFS= read -r LINE
do
printf '%s%s\n' "deny from " "${LINE}" >> "$_tmpapache8"
done < $_input8
printf '%s\n' "$_end8"  >> "$_tmpapache8"
mv $_tmpapache8 $_inputdb8
ed -s $_inputdb8<<\IN
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
rm $_inputdb8

# *******************************
# Nibbler SEO - Create and Insert
# *******************************

printf '%s\n' "$_start9" >> "$_tmpapache9"
while IFS= read -r LINE
do
printf '%s%s\n' "deny from " "${LINE}" >> "$_tmpapache9"
done < $_input9
printf '%s\n' "$_end9"  >> "$_tmpapache9"
mv $_tmpapache9 $_inputdb9
ed -s $_inputdb9<<\IN
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
rm $_inputdb9

# ****************************************
# CLOUDFLARE IP RANGES - Create and Insert
# ****************************************

printf '%s\n' "$_start10" >> "$_tmpapache10"
while IFS= read -r LINE
do
printf '%s%s\n' "Allow from " "${LINE}" >> "$_tmpapache10"
done < $_input10
printf '%s\n' "$_end10"  >> "$_tmpapache10"
mv $_tmpapache10 $_inputdb10
ed -s $_inputdb10<<\IN
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
rm $_inputdb10

# Copy files to correct folder
# **********************************************
sudo cp $_apache3 /home/travis/build/mitchellkrogza/apache-ultimate-bad-bot-blocker/_other_distros/CentOS6/conf.d/globalblacklist.conf

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

printf '%s\n%s\n%s%s\n%s%s\n%s%s\n%s%s\n%s\n%s\n' "$_startmarker" "###################################################" "### Version: " "$MY_GIT_TAG" "### Updated: " "$_now" "### Bad Referrer Count: " "$BAD_REFERRERS" "### Bad Bot Count: " "$BAD_BOTS" "###################################################" "$_endmarker" >> "$_tmpapacheA"
mv $_tmpapacheA $_inputdbA
ed -s $_inputdbA<<\IN
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
rm $_inputdbA

# ************************************
# GOOD USER AGENTS - Create and Insert
# ************************************

printf '%s\n' "$_start1" >> "$_tmpapache1"
while IFS= read -r LINE
do
printf '%s"%s%s%s" %s\n' "BrowserMatchNoCase " "^(.*?)(\b" "${LINE}" "\b)(.*)$" "$_action1" >> "$_tmpapache1"
done < $_input1
printf '%s\n' "$_end1"  >> "$_tmpapache1"
mv $_tmpapache1 $_inputdb1
ed -s $_inputdb1<<\IN
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
rm $_inputdb1

# ********************************
# ALLOWED BOTS - Create and Insert
# ********************************

printf '%s\n' "$_start2" >> "$_tmpapache2"
while IFS= read -r LINE
do
printf '%s"%s%s%s" %s\n' "BrowserMatchNoCase " "^(.*?)(\b" "${LINE}" "\b)(.*)$" "$_action1" >> "$_tmpapache2"
done < $_input2
printf '%s\n' "$_end2"  >> "$_tmpapache2"
mv $_tmpapache2 $_inputdb2
ed -s $_inputdb2<<\IN
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
rm $_inputdb2

# ********************************
# LIMITED BOTS - Create and Insert
# ********************************

printf '%s\n' "$_start3" >> "$_tmpapache3"
while IFS= read -r LINE
do
printf '%s"%s%s%s" %s\n' "BrowserMatchNoCase " "^(.*?)(\b" "${LINE}" "\b)(.*)$" "$_action1" >> "$_tmpapache3"
done < $_input3
printf '%s\n' "$_end3"  >> "$_tmpapache3"
mv $_tmpapache3 $_inputdb3
ed -s $_inputdb3<<\IN
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
rm $_inputdb3

# ****************************
# BAD BOTS - Create and Insert
# ****************************

printf '%s\n' "$_start4" >> "$_tmpapache4"
while IFS= read -r LINE
do
printf '%s"%s%s%s" %s\n' "BrowserMatchNoCase " "^(.*?)(\b" "${LINE}" "\b)(.*)$" "$_action2" >> "$_tmpapache4"
done < $_input4
printf '%s\n' "$_end4"  >> "$_tmpapache4"
mv $_tmpapache4 $_inputdb4
ed -s $_inputdb4<<\IN
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
rm $_inputdb4

# ********************************
# BAD REFERERS - Create and Insert
# ********************************

printf '%s\n' "$_start5" >> "$_tmpapache5"
while IFS= read -r LINE
do
printf '%s\n' "${LINE}" >> "$_tmpapache5"
done < $_input5
printf '%s\n' "$_end5"  >> "$_tmpapache5"
mv $_tmpapache5 $_inputdb5
ed -s $_inputdb5<<\IN
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
rm $_inputdb5

# ************************************
# GOOGLE IP RANGES - Create and Insert
# ************************************

printf '%s\n' "$_start6" >> "$_tmpapache6"
while IFS= read -r LINE
do
printf '%s%s\n' "Allow from " "${LINE}" >> "$_tmpapache6"
done < $_input6
printf '%s\n' "$_end6"  >> "$_tmpapache6"
mv $_tmpapache6 $_inputdb6
ed -s $_inputdb6<<\IN
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
rm $_inputdb6

# **********************************
# BING IP RANGES - Create and Insert
# **********************************

printf '%s\n' "$_start7" >> "$_tmpapache7"
while IFS= read -r LINE
do
printf '%s%s\n' "Allow from " "${LINE}" >> "$_tmpapache7"
done < $_input7
printf '%s\n' "$_end7"  >> "$_tmpapache7"
mv $_tmpapache7 $_inputdb7
ed -s $_inputdb7<<\IN
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
rm $_inputdb7

# *********************************************
# Wordpress Theme Detectors - Create and Insert
# *********************************************

printf '%s\n' "$_start8" >> "$_tmpapache8"
while IFS= read -r LINE
do
printf '%s%s\n' "deny from " "${LINE}" >> "$_tmpapache8"
done < $_input8
printf '%s\n' "$_end8"  >> "$_tmpapache8"
mv $_tmpapache8 $_inputdb8
ed -s $_inputdb8<<\IN
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
rm $_inputdb8

# *******************************
# Nibbler SEO - Create and Insert
# *******************************

printf '%s\n' "$_start9" >> "$_tmpapache9"
while IFS= read -r LINE
do
printf '%s%s\n' "deny from " "${LINE}" >> "$_tmpapache9"
done < $_input9
printf '%s\n' "$_end9"  >> "$_tmpapache9"
mv $_tmpapache9 $_inputdb9
ed -s $_inputdb9<<\IN
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
rm $_inputdb9

# ****************************************
# CLOUDFLARE IP RANGES - Create and Insert
# ****************************************

printf '%s\n' "$_start10" >> "$_tmpapache10"
while IFS= read -r LINE
do
printf '%s%s\n' "Allow from " "${LINE}" >> "$_tmpapache10"
done < $_input10
printf '%s\n' "$_end10"  >> "$_tmpapache10"
mv $_tmpapache10 $_inputdb10
ed -s $_inputdb10<<\IN
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
rm $_inputdb10

# Copy files to correct folder
# **********************************************
sudo cp $_apache4 /home/travis/build/mitchellkrogza/apache-ultimate-bad-bot-blocker/_other_distros/CentOS7/custom.d/globalblacklist.conf


exit 0
