#!/bin/bash
# Setup Apache for Testing the Apache Ultimate Bad Bot Blocker on apache 2.4 without mod_access_compat
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

# *******************************************************
# First lets stop Apache before we make changes like this
# *******************************************************

printf '%s\n%s\n%s\n\n' "#################################################" "Stop Apache 2.4 before cleanup of 2.2 Test Files" "#################################################"
sudo service apache2 stop

# ********************
# Disable Default Site
# ********************

printf '%s\n%s\n%s\n\n' "#########################" "Disable Apache 2.2 Vhost" "#########################"
sudo a2dissite default.conf

# ********************************************************************************************
# Copy our Apache 2.4 virtual host template to sites-enabled overwriting the default site conf
# ********************************************************************************************

printf '%s\n%s\n%s\n\n' "#########################" "Remove Apache 2.2 Vhost" "#########################"
sudo rm /etc/apache2/sites-available/default.conf

printf '%s\n%s\n%s\n\n' "#########################" "Install Apache 2.4 Vhost" "#########################"
sudo cp $TRAVIS_BUILD_DIR/.dev-tools/defaultsite24.conf /etc/apache2/sites-available/default.conf

# *******************
# Enable Default Site
# *******************

printf '%s\n%s\n%s\n\n' "#########################" "Enable Apache 2.4 Vhost" "#########################"
sudo a2ensite default.conf

# *************************
# Disable mod_access_compat
# *************************

printf '%s\n%s\n%s\n\n' "############################" "Disable mod access_compat" "############################"
sudo a2dismod access_compat

# ********************************************************************************************
# Replace apache2.conf with out Apache 2.4 version of apache2.conf to /etc/apache2
# ********************************************************************************************

#sudo service apache2 stop
#sudo mv /etc/apache2/apache2.conf /etc/apache2/apache2.bak
#sudo cp $TRAVIS_BUILD_DIR/.dev-tools/apache2.conf /etc/apache2/apache2.conf
#sudo service apache2 restart

# **************************************
# Get new files from Repo Apache_2.4
# **************************************

printf '%s\n%s\n%s\n\n' "#################################" "Download Apache 2.4 Files from Repo" "#################################"
sudo rm /etc/apache2/custom.d/*.conf
sudo wget https://raw.githubusercontent.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/master/Apache_2.4/custom.d/globalblacklist.conf -O /etc/apache2/custom.d/globalblacklist.conf
sudo wget https://raw.githubusercontent.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/master/Apache_2.4/custom.d/whitelist-ips.conf -O /etc/apache2/custom.d/whitelist-ips.conf
sudo wget https://raw.githubusercontent.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/master/Apache_2.4/custom.d/whitelist-domains.conf -O /etc/apache2/custom.d/whitelist-domains.conf
sudo wget https://raw.githubusercontent.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/master/Apache_2.4/custom.d/blacklist-ips.conf -O /etc/apache2/custom.d/blacklist-ips.conf
sudo wget https://raw.githubusercontent.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/master/Apache_2.4/custom.d/bad-referrer-words.conf -O /etc/apache2/custom.d/bad-referrer-words.conf
sudo wget https://raw.githubusercontent.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/master/Apache_2.4/custom.d/blacklist-user-agents.conf -O /etc/apache2/custom.d/blacklist-user-agents.conf

# *************************
# Set Ownership of /var/www
# *************************

printf '%s\n%s\n%s\n\n' "#################################" "Set Ownership of /var/www/" "#################################"
sudo chown -R www-data:www-data /var/www/

# **********************
# Now Start Apache Again
# **********************

printf '%s\n%s\n%s\n\n' "#################################" "Force Restart of Apache 2.4" "#################################"
sudo service apache2 restart

# **********************
# Test the Apache Config
# **********************

printf '%s\n%s\n%s\n\n' "#################################" "Run Apache 2.4 Config Test" "#################################"
sudo apache2ctl configtest

printf '%s\n%s\n%s\n\n' "####################" "Run Some Curl Tests" "####################"
curl -I http://local.dev
curl -A "80legs" http://local.dev
curl -A "360Spider" http://local.dev
curl -A "Acunetix" http://local.dev
curl -A "GoogleBot" http://local.dev

# *****************************************
# Get a copy of all conf files for checking
# *****************************************

sudo cp /etc/apache2/custom.d/*.conf $TRAVIS_BUILD_DIR/.dev-tools/_conf_files_2.4/
sudo cp /etc/apache2/apache2.conf $TRAVIS_BUILD_DIR/.dev-tools/_conf_files_2.4/apache2.conf
sudo cp /etc/apache2/sites-available/default.conf $TRAVIS_BUILD_DIR/.dev-tools/_conf_files_2.4/default.conf

# *****************************************************************************************
# Travis now moves into running the rest of the tests in the script: section of .travis.yml
# *****************************************************************************************

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