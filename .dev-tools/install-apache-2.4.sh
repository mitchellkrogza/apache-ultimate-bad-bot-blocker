#!/bin/bash
# Setup Apache for Testing the Apache Ultimate Bad Bot Blocker on apache 2.4.34
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
# Stop Apache 2.2.25
# ******************

echo "Stopping Apache 2.2"
sudo /usr/local/apache2/bin/apachectl stop

# **********************
# Clean Up Apache 2.2.25
# **********************

sudo rm -rf /usr/local/apache2/
ls -la /usr/local
sudo rm -rf /tmp/zlib-1.2.11/
sudo rm -rf /tmp/httpd-2.2.25/
ls -la /tmp

# ***************************************************
# Install latest Apache from Repo: ppa:ondrej/apache2
# ***************************************************

sudo add-apt-repository ppa:ondrej/apache2 -y
sudo apt-get update
sudo apt-get install -y apache2 apache2-utils

# **************************
# Show Loaded apache Modules
# **************************

printf '%s\n%s\n%s\n\n' "#################################" "Show Loaded Apache Modules" "#################################"
sudo apache2ctl -M

# **************************
# Show Apache Version
# **************************

printf '%s\n%s\n%s\n\n' "#####################################" "Show Apache Version Information" "#####################################"
sudo apache2ctl -V

# ***********************
# Set ServerName Globally
# ***********************

sudo cp ${TRAVIS_BUILD_DIR}/.dev-tools/servername.conf /etc/apache2/conf-available/servername.conf
sudo a2enconf servername

# ****************************************
# Put modified 000-default.conf into place
# ****************************************

sudo rm /etc/apache2/sites-available/*
sudo rm /etc/apache2/sites-enabled/*

# ****************************
# Put testsite.conf into place
# ****************************

sudo cp ${TRAVIS_BUILD_DIR}/.dev-tools/_conf_files_for_testing/apache2.4.34/testsite.conf /etc/apache2/sites-available/

sudo a2ensite testsite.conf

# Reload Apache
sudo service apache2 reload

# *************************************
# Get files from Repo Apache_2.4
# *************************************

sudo mkdir /etc/apache2/custom.d
sudo wget https://raw.githubusercontent.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/master/Apache_2.4/custom.d/globalblacklist.conf -O /etc/apache2/custom.d/globalblacklist.conf
sudo wget https://raw.githubusercontent.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/master/Apache_2.4/custom.d/whitelist-ips.conf -O /etc/apache2/custom.d/whitelist-ips.conf
sudo wget https://raw.githubusercontent.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/master/Apache_2.4/custom.d/whitelist-domains.conf -O /etc/apache2/custom.d/whitelist-domains.conf
sudo wget https://raw.githubusercontent.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/master/Apache_2.4/custom.d/blacklist-ips.conf -O /etc/apache2/custom.d/blacklist-ips.conf
sudo wget https://raw.githubusercontent.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/master/Apache_2.4/custom.d/bad-referrer-words.conf -O /etc/apache2/custom.d/bad-referrer-words.conf
sudo wget https://raw.githubusercontent.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/master/Apache_2.4/custom.d/blacklist-user-agents.conf -O /etc/apache2/custom.d/blacklist-user-agents.conf

# **********************
# Test the Apache Config
# **********************

printf '%s\n%s\n%s\n\n' "#################################" "Run Apache 2.4 Config Test" "#################################"
sudo apache2ctl configtest

# ******************
# Test Apache 2 Curl
# ******************

sudo wget -qO- http://local.dev

# *************************************************
# Curl Test 1 - Check for Bad Bot "80legs"
# *************************************************

printf "\n\nTEST FOR 80legs User-Agent\n\n"
curl -A "80legs" http://local.dev:80/index.html

# *****************************
# Now Disable mod_access_compat
# *****************************

printf '%s\n%s\n%s\n\n' "############################" "Disable mod access_compat" "############################"
sudo a2dismod access_compat

# *************
# Reload Apache
# *************

sudo service apache2 reload
sudo service apache2 restart

# *******************************
# Test with modified apache2.conf
# *******************************

sudo cp ${TRAVIS_BUILD_DIR}/.dev-tools/_conf_files_for_testing/apache2.4.34/apache2.conf /etc/apache2/

# *************
# Reload Apache
# *************

sudo service apache2 reload
sudo service apache2 restart

# *************************************************
# Curl Test 1 - Check for Bad Bot "80legs"
# *************************************************

printf "\n\nTEST FOR 80legs User-Agent\n\n"
curl -A "80legs" http://local.dev:80/index.html

# ******************************************************************
# Curl Test 2 - Check for Bad Referrer "000free.us"
# ******************************************************************

printf "\n\nTEST FOR 000free.us Referrer\n\n"
curl -I http://local.dev:80/index.html -e http://000free.us

# *************************************************
# Curl Test 3 - Check for Good Bot "Googlebot"
# *************************************************

printf "\n\nTEST FOR GoogleBot User-Agent\n\n"
curl -A "Googlebot" http://local.dev:80/index.html

# ******************************************************************
# Curl Test 4 - Check for Good Referrer "google.com"
# ******************************************************************

printf "\n\nTEST FOR google.com Referrer\n\n"
curl -I http://local.dev:80/index.html -e http://google.com

# *****************************************
# Get a copy of all conf files for checking
# *****************************************

sudo cp /etc/apache2/custom.d/*.conf ${TRAVIS_BUILD_DIR}/.dev-tools/_test_results/_conf_files_2.4/
sudo cp /etc/apache2/apache2.conf ${TRAVIS_BUILD_DIR}/.dev-tools/_test_results/_conf_files_2.4/apache2.conf
sudo cp /etc/apache2/sites-available/* ${TRAVIS_BUILD_DIR}/.dev-tools/_test_results/_conf_files_2.4/

# ********************************************************************
# Place an older globalblacklist.conf into place to test update script
# ********************************************************************

sudo cp ${TRAVIS_BUILD_DIR}/.dev-tools/_conf_files_for_testing/apache2.4.34/old-globalblacklist.conf /etc/apache2/custom.d/globalblacklist.conf

# *****************************
# Download and test the updater
# *****************************

sudo wget https://raw.githubusercontent.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/master/update-apacheblocker.sh -O ${TRAVIS_BUILD_DIR}/.dev-tools/_conf_files_for_testing/apache2.4.34/update-apacheblocker.sh

sed "s/email@example.com/mitchellkrog@gmail.com/g" ${TRAVIS_BUILD_DIR}/.dev-tools/_conf_files_for_testing/apache2.4.34/update-apacheblocker.sh > ${TRAVIS_BUILD_DIR}/.dev-tools/_conf_files_for_testing/apache2.4.34/update-apacheblocker.tmp && sudo mv ${TRAVIS_BUILD_DIR}/.dev-tools/_conf_files_for_testing/apache2.4.34/update-apacheblocker.tmp ${TRAVIS_BUILD_DIR}/.dev-tools/_conf_files_for_testing/apache2.4.34/update-apacheblocker.sh

cat ${TRAVIS_BUILD_DIR}/.dev-tools/_conf_files_for_testing/apache2.4.34/update-apacheblocker.sh

sudo chmod +x ${TRAVIS_BUILD_DIR}/.dev-tools/_conf_files_for_testing/apache2.4.34/update-apacheblocker.sh
sudo ${TRAVIS_BUILD_DIR}/.dev-tools/_conf_files_for_testing/apache2.4.34/update-apacheblocker.sh


# **********************
# Exit With Error Number
# **********************

exit ${?}


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