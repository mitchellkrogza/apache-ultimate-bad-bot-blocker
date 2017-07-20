#!/bin/bash
# Bad bot generator for Apache 2.4
# Created by: https://github.com/mitchellkrogza (mitchellkrog@gmail.com)
# Copyright: Mitchell Krog - https://github.com/mitchellkrogza

# Written in bash as it is universal to virtually every linux distribution


# ******************
# Set Some Variables
# ******************

YEAR=$(date +"%Y")
MONTH=$(date +"%m")
MY_GIT_TAG=V2.$YEAR.$MONTH
_now="$(date)"

# *************************************
# Update Repo with Travis Ci Last Build
#**************************************

cd /home/mitchellkrog/apache-blocker
sudo git pull origin master
cd /home/mitchellkrog/botlists

# ****************************************************
# Get Latest Updated List of Referrers from Nginx Repo
# ****************************************************

sudo wget https://raw.githubusercontent.com/mitchellkrogza/nginx-ultimate-bad-bot-blocker/master/_generator_lists/bad-referrers.list -O /home/mitchellkrog/botlists/lists/06-bad-referers.list

# *******************************************************************
# Generate our apache bad referrers with the correct Regex formatting
# *******************************************************************

php ./apache-referers-regex.php

# *************************************************
# Set some variables after downloading current list
# *************************************************

BAD_REFERRERS=$(wc -l < ./lists/06-bad-referers-apache.list)
BAD_BOTS=$(wc -l < ./lists/04-bad-user-agents.list)

# Setup input bots and referer lists
_input1=./lists/01-good-user-agents.list
_input2=./lists/02-allowed-user-agents.list
_input3=./lists/03-limited-user-agents.list
_input4=./lists/04-bad-user-agents.list
_input5=./lists/06-bad-referers-apache.list
_input6=./lists/09-google-ip-ranges.list
_input7=./lists/10-bing-ip-ranges.list
_input8=./lists/14b-wordpress-theme-detectors-apache.list
_input9=./lists/15-nibbler-seo.list
_input10=./lists/16-cloudflare-ip-ranges.list
_input11=./lists/06-bad-referers.list

# Temporary database files we create
_inputdbA=./lastupdated.db
_inputdb1=./lists/good-user-agents.db
_inputdb2=./lists/allowed-user-agents.db
_inputdb3=./lists/limited-user-agents.db
_inputdb4=./lists/bad-user-agents.db
_inputdb5=./lists/bad-referers.db
_inputdb6=./lists/google-ip-ranges.db
_inputdb7=./lists/bing-ip-ranges.db
_inputdb8=./lists/wordpress-theme-detectors.db
_inputdb9=./lists/nibbler-seo.db
_inputdb10=./lists/cloudflare-ip-ranges.db

# Declare Apache template and temp variables
_apache=./apachetemplate-public
_tmpapacheA=tmpapacheA
_tmpapacheB=tmpapacheB
_tmpapache1=tmpapache1
_tmpapache2=tmpapache2
_tmpapache3=tmpapache3
_tmpapache4=tmpapache4
_tmpapache5=tmpapache5
_tmpapache6=tmpapache6
_tmpapache7=tmpapache7
_tmpapache8=tmpapache8
_tmpapache9=tmpapache9
_tmpapache10=tmpapache10

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

_action1="good_bot=1"
_action2="bad_bot=1"
_action3="spam_ref=1"
_action4="good_ref=1"

# *******************************************************************************
# PRINT VERSION, SCRIPT RUNTIME and UPDATE INFORMATION INTO GLOBALBLACKLIST FILES
# *******************************************************************************

printf '%s\n%s\n%s%s\n%s%s\n%s%s\n%s%s\n%s\n%s\n' "$_startmarker" "###################################################" "### Version: " "$MY_GIT_TAG" "### Updated: " "$_now" "### Bad Referrer Count: " "$BAD_REFERRERS" "### Bad Bot Count: " "$BAD_BOTS" "###################################################" "$_endmarker" >> "$_tmpapacheA"
mv $_tmpapacheA $_inputdbA
ed -s $_inputdbA<<\IN
1,/### Version Information #/d
/### Version Information ##/,$d
,d
.r ./apachetemplate-public
/### Version Information #/x
.t.
.,/### Version Information ##/-d
#,p
#,p used to print output replaced with w below to write
w ./apachetemplate-public
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
.r ./apachetemplate-public
/# START GOOD BOTS ### DO NOT EDIT THIS LINE AT ALL ###/x
.t.
.,/# END GOOD BOTS ### DO NOT EDIT THIS LINE AT ALL ###/-d
#,p
#,p used to print output replaced with w below to write
w ./apachetemplate-public
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
.r ./apachetemplate-public
/# START ALLOWED BOTS ### DO NOT EDIT THIS LINE AT ALL ###/x
.t.
.,/# END ALLOWED BOTS ### DO NOT EDIT THIS LINE AT ALL ###/-d
w ./apachetemplate-public
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
.r ./apachetemplate-public
/# START LIMITED BOTS ### DO NOT EDIT THIS LINE AT ALL ###/x
.t.
.,/# END LIMITED BOTS ### DO NOT EDIT THIS LINE AT ALL ###/-d
w ./apachetemplate-public
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
.r ./apachetemplate-public
/# START BAD BOTS ### DO NOT EDIT THIS LINE AT ALL ###/x
.t.
.,/# END BAD BOTS ### DO NOT EDIT THIS LINE AT ALL ###/-d
w ./apachetemplate-public
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
.r ./apachetemplate-public
/# START BAD REFERERS ### DO NOT EDIT THIS LINE AT ALL ###/x
.t.
.,/# END BAD REFERERS ### DO NOT EDIT THIS LINE AT ALL ###/-d
w ./apachetemplate-public
q
IN
rm $_inputdb5

# ************************************
# GOOGLE IP RANGES - Create and Insert
# ************************************

printf '%s\n' "$_start6" >> "$_tmpapache6"
while IFS= read -r LINE
do
printf '%s %s\n' "Allow from" "${LINE}" >> "$_tmpapache6"
done < $_input6
printf '%s\n' "$_end6"  >> "$_tmpapache6"
mv $_tmpapache6 $_inputdb6
ed -s $_inputdb6<<\IN
1,/# START GOOGLE IP RANGES ### DO NOT EDIT THIS LINE AT ALL ###/d
/# END GOOGLE IP RANGES ### DO NOT EDIT THIS LINE AT ALL ###/,$d
,d
.r ./apachetemplate-public
/# START GOOGLE IP RANGES ### DO NOT EDIT THIS LINE AT ALL ###/x
.t.
.,/# END GOOGLE IP RANGES ### DO NOT EDIT THIS LINE AT ALL ###/-d
w ./apachetemplate-public
q
IN
rm $_inputdb6

# **********************************
# BING IP RANGES - Create and Insert
# **********************************

printf '%s\n' "$_start7" >> "$_tmpapache7"
while IFS= read -r LINE
do
printf '%s %s\n' "Allow from" "${LINE}" >> "$_tmpapache7"
done < $_input7
printf '%s\n' "$_end7"  >> "$_tmpapache7"
mv $_tmpapache7 $_inputdb7
ed -s $_inputdb7<<\IN
1,/# START BING IP RANGES ### DO NOT EDIT THIS LINE AT ALL ###/d
/# END BING IP RANGES ### DO NOT EDIT THIS LINE AT ALL ###/,$d
,d
.r ./apachetemplate-public
/# START BING IP RANGES ### DO NOT EDIT THIS LINE AT ALL ###/x
.t.
.,/# END BING IP RANGES ### DO NOT EDIT THIS LINE AT ALL ###/-d
w ./apachetemplate-public
q
IN
rm $_inputdb7

# *********************************************
# Wordpress Theme Detectors - Create and Insert
# *********************************************

printf '%s\n' "$_start8" >> "$_tmpapache8"
while IFS= read -r LINE
do
printf '%s %s\n' "deny from" "${LINE}" >> "$_tmpapache8"
done < $_input8
printf '%s\n' "$_end8"  >> "$_tmpapache8"
mv $_tmpapache8 $_inputdb8
ed -s $_inputdb8<<\IN
1,/# START WP THEME DETECTORS ### DO NOT EDIT THIS LINE AT ALL ###/d
/# END WP THEME DETECTORS ### DO NOT EDIT THIS LINE AT ALL ###/,$d
,d
.r ./apachetemplate-public
/# START WP THEME DETECTORS ### DO NOT EDIT THIS LINE AT ALL ###/x
.t.
.,/# END WP THEME DETECTORS ### DO NOT EDIT THIS LINE AT ALL ###/-d
w ./apachetemplate-public
q
IN
rm $_inputdb8

# *******************************
# Nibbler SEO - Create and Insert
# *******************************

printf '%s\n' "$_start9" >> "$_tmpapache9"
while IFS= read -r LINE
do
printf '%s %s\n' "deny from" "${LINE}" >> "$_tmpapache9"
done < $_input9
printf '%s\n' "$_end9"  >> "$_tmpapache9"
mv $_tmpapache9 $_inputdb9
ed -s $_inputdb9<<\IN
1,/# START NIBBLER ### DO NOT EDIT THIS LINE AT ALL ###/d
/# END NIBBLER ### DO NOT EDIT THIS LINE AT ALL ###/,$d
,d
.r ./apachetemplate-public
/# START NIBBLER ### DO NOT EDIT THIS LINE AT ALL ###/x
.t.
.,/# END NIBBLER ### DO NOT EDIT THIS LINE AT ALL ###/-d
w ./apachetemplate-public
q
IN
rm $_inputdb9

# ****************************************
# CLOUDFLARE IP RANGES - Create and Insert
# ****************************************

printf '%s\n' "$_start10" >> "$_tmpapache10"
while IFS= read -r LINE
do
printf '%s %s\n' "Allow from" "${LINE}" >> "$_tmpapache10"
done < $_input10
printf '%s\n' "$_end10"  >> "$_tmpapache10"
mv $_tmpapache10 $_inputdb10
ed -s $_inputdb10<<\IN
1,/# START CLOUDFLARE IP RANGES ### DO NOT EDIT THIS LINE AT ALL ###/d
/# END CLOUDFLARE IP RANGES ### DO NOT EDIT THIS LINE AT ALL ###/,$d
,d
.r ./apachetemplate-public
/# START CLOUDFLARE IP RANGES ### DO NOT EDIT THIS LINE AT ALL ###/x
.t.
.,/# END CLOUDFLARE IP RANGES ### DO NOT EDIT THIS LINE AT ALL ###/-d
w ./apachetemplate-public
q
IN
rm $_inputdb10

# Create Google Disavow File
# ****************************************

sudo truncate -s 0 ./google-disavow.txt
for line in $(cat $_input11); do
printf "domain:${line}\n" >> ./google-disavow.txt
done

# Generate Google Exclude File
# ****************************
php ./google-exclude.php

# Generate .htaccess Files
# ************************
php ./htaccess.php

# Copy files to git working directory and commit
# **********************************************
sudo ./generaterobots.sh
sudo cp ./google-exclude-*.txt /home/mitchellkrog/apache-blocker/_google_analytics_ghost_spam/
sudo cp ./google-disavow.txt /home/mitchellkrog/apache-blocker/_google_webmaster_disavow_links/google-disavow.txt
sudo cp $_input1 /home/mitchellkrog/apache-blocker/_generator_lists/good-user-agents.list
sudo cp $_input2 /home/mitchellkrog/apache-blocker/_generator_lists/allowed-user-agents.list
sudo cp $_input3 /home/mitchellkrog/apache-blocker/_generator_lists/limited-user-agents.list
sudo cp $_input4 /home/mitchellkrog/apache-blocker/_generator_lists/bad-user-agents.list
sudo cp $_input11 /home/mitchellkrog/apache-blocker/_generator_lists/bad-referrers.list
sudo cp $_input6 /home/mitchellkrog/apache-blocker/_generator_lists/google-ip-ranges.list
sudo cp $_input7 /home/mitchellkrog/apache-blocker/_generator_lists/bing-ip-ranges.list
sudo cp ./robots.txt /home/mitchellkrog/apache-blocker/robots.txt/robots.txt
sudo cp ./htaccess-mod_rewrite.txt /home/mitchellkrog/apache-blocker/_htaccess_versions/htaccess-mod_rewrite.txt
sudo cp ./htaccess-mod_setenvif.txt /home/mitchellkrog/apache-blocker/_htaccess_versions/htaccess-mod_setenvif.txt
sudo cp $_apache /home/mitchellkrog/apache-blocker/custom.d/globalblacklist.conf
sudo cp $_apache /home/mitchellkrog/apache-blocker/Apache_2.2/custom.d/globalblacklist.conf
sudo ./apachecentos.sh
sudo ./apachecentos7.sh
cd /home/mitchellkrog/apache-blocker
sudo git add .
sudo git commit -am "Start Splitting between Apache 2.2 and 2.4 Versions - Different Access Control Structures"
sudo git push origin master

# Enable the section below to automatically move the generated
# script into the /etc/apache2/custom.d folder for you and restart apache2

#sudo cp $_apache /etc/apache2/custom.d/globalblacklist.conf
#sudo service apache2 reload

exit 0
