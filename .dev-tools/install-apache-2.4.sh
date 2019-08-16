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

# ------------------------
# Set Terminal Font Colors
# ------------------------

bold=$(tput bold)
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
blue=$(tput setaf 4)
magenta=$(tput setaf 5)
cyan=$(tput setaf 6)
white=$(tput setaf 7)
defaultcolor=$(tput setaf default)


# ******************
# Stop Apache 2.2.25
# ******************

echo "${bold}${yellow}Stopping Apache 2.2"
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

echo "${bold}${green}Show Loaded Apache Modules"
sudo apache2ctl -M

# **************************
# Show Apache Version
# **************************

echo "${bold}${green}Show Apache Version Information"
sudo apache2ctl -V

# ***********************
# Set ServerName Globally
# ***********************

echo "${bold}${yellow}Set Apache ServerName"
sudo cp ${TRAVIS_BUILD_DIR}/.dev-tools/servername.conf /etc/apache2/conf-available/servername.conf
sudo a2enconf servername

# ****************************************
# Put modified 000-default.conf into place
# ****************************************

echo "${bold}${yellow}Enable Apache VHost"
sudo rm /etc/apache2/sites-available/*
sudo rm /etc/apache2/sites-enabled/*
sudo cp ${TRAVIS_BUILD_DIR}/.dev-tools/_conf_files_for_testing/apache2.4.34/testsite.conf /etc/apache2/sites-available/
sudo a2ensite testsite.conf

echo "${bold}${yellow}Reloading Apache"
sudo service apache2 reload

# *************************************
# Get files from Repo Apache_2.4
# *************************************

echo "${bold}${green}Download Blocker Files from Repo"
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

echo "${bold}${green}Run Apache 2.4 Config Test"
sudo apache2ctl configtest

# ******************
# Test Apache 2 Curl
# ******************

echo "${bold}${yellow}Test wget"
sudo wget -qO- http://local.dev

# *****************************
# Now Disable mod_access_compat
# *****************************

echo "${bold}${yellow}Disable mod access_compat"
sudo a2dismod access_compat

# *************
# Reload Apache
# *************

echo "${bold}${yellow}Restarting Apache"
sudo service apache2 reload
sudo service apache2 restart

# *******************************
# Test with modified apache2.conf
# *******************************

echo "${bold}${yellow}Test Modified apache2.conf"
sudo cp ${TRAVIS_BUILD_DIR}/.dev-tools/_conf_files_for_testing/apache2.4.34/apache2.conf /etc/apache2/

# *************
# Reload Apache
# *************

echo "${bold}${yellow}Restarting Apache"
sudo service apache2 reload
sudo service apache2 restart

# ********************************************************************
# Place an older globalblacklist.conf into place to test update script
# ********************************************************************

echo "${bold}${yellow}Install old version of blacklist to test updater"
sudo cp ${TRAVIS_BUILD_DIR}/.dev-tools/_conf_files_for_testing/apache2.4.34/old-globalblacklist.conf /etc/apache2/custom.d/globalblacklist.conf

# *****************************
# Download and test the updater
# *****************************

echo "${bold}${yellow}Download update-apacheblocker.sh"
sudo wget https://raw.githubusercontent.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/master/update-apacheblocker.sh -O ${TRAVIS_BUILD_DIR}/.dev-tools/_conf_files_for_testing/apache2.4.34/update-apacheblocker.sh
sed -n "s/email@example.com/mitchellkrog@gmail.com/g" ${TRAVIS_BUILD_DIR}/.dev-tools/_conf_files_for_testing/apache2.4.34/update-apacheblocker.sh > ${TRAVIS_BUILD_DIR}/.dev-tools/_conf_files_for_testing/apache2.4.34/update-apacheblocker.tmp && sudo mv ${TRAVIS_BUILD_DIR}/.dev-tools/_conf_files_for_testing/apache2.4.34/update-apacheblocker.tmp ${TRAVIS_BUILD_DIR}/.dev-tools/_conf_files_for_testing/apache2.4.34/update-apacheblocker.sh
echo "${bold}${yellow}Test update-apacheblocker.sh"
sudo chmod +x ${TRAVIS_BUILD_DIR}/.dev-tools/_conf_files_for_testing/apache2.4.34/update-apacheblocker.sh
sudo bash ${TRAVIS_BUILD_DIR}/.dev-tools/_conf_files_for_testing/apache2.4.34/update-apacheblocker.sh

# ***********************************************************************************
# Put Latest Generated globalblacklist.conf into place for correct testing of changes
# ***********************************************************************************

echo "${bold}${yellow}Place latest generated version of globalblacklist.conf into place"
sudo cp /home/travis/build/mitchellkrogza/apache-ultimate-bad-bot-blocker/Apache_2.4/custom.d/globalblacklist.conf /etc/apache2/custom.d/globalblacklist.conf

# *************
# Reload Apache
# *************

echo "${bold}${yellow}Restarting Apache"
sudo service apache2 reload
sudo service apache2 restart

# *****************************************
# Get a copy of all conf files for checking
# *****************************************

echo "${bold}${yellow}Backup Config Files"
sudo cp /etc/apache2/custom.d/*.conf ${TRAVIS_BUILD_DIR}/.dev-tools/_test_results/_conf_files_2.4/
sudo cp /etc/apache2/apache2.conf ${TRAVIS_BUILD_DIR}/.dev-tools/_test_results/_conf_files_2.4/apache2.conf
sudo cp /etc/apache2/sites-available/* ${TRAVIS_BUILD_DIR}/.dev-tools/_test_results/_conf_files_2.4/


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
