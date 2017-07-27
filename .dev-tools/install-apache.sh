#!/bin/bash
# Setup Apache for Testing the Apache Ultimate Bad Bot Blocker
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

# *****************************
# Install older default Apache2
# *****************************
#sudo apt-get update
#sudo apt-get install -y apache2 apache2-utils

# ***************************************************
# Install latest Apache from Repo: ppa:ondrej/apache2
# ***************************************************

sudo add-apt-repository ppa:ondrej/apache2 -y
sudo apt-get update
sudo apt-get install -y apache2 apache2-utils

# ****************************
# Install zip for our releases
# ****************************

sudo apt-get install zip -y

# ******************************************
# Delete any existing default site in Apache
# ******************************************

sudo rm /etc/apache2/sites-available/*
sudo rm /etc/apache2/sites-enabled/*

# *********************************************************************************
# Copy our virtual host template to sites-enabled overwriting the default site conf
# *********************************************************************************

sudo cp $TRAVIS_BUILD_DIR/.dev-tools/defaultsite.conf /etc/apache2/sites-available/default.conf

# *****************************************************
# Copy basic testing index.html file into /var/www/html
# *****************************************************

sudo cp $TRAVIS_BUILD_DIR/.dev-tools/index.html /var/www/html/index.html

# *************************
# Set Ownership of /var/www
# *************************

sudo chown -R www-data:www-data /var/www/

# ******************************
# Enable required Apache modules
# ******************************

sudo a2enmod rewrite
sudo a2enmod expires
sudo a2enmod headers
sudo a2enmod mime

# ***********************
# Enable the Default Site
# ***********************

sudo a2ensite default.conf

# ***********************
# Set ServerName Globally
# ***********************

sudo cp $TRAVIS_BUILD_DIR/.dev-tools/servername.conf /etc/apache2/conf-available/servername.conf
sudo a2enconf servername

# *************************************
# Get files from Repo Apache_2.2
# *************************************

sudo mkdir /etc/apache2/custom.d
sudo wget https://raw.githubusercontent.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/master/Apache_2.2/custom.d/globalblacklist.conf -O /etc/apache2/custom.d/globalblacklist.conf
sudo wget https://raw.githubusercontent.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/master/Apache_2.2/custom.d/whitelist-ips.conf -O /etc/apache2/custom.d/whitelist-ips.conf
sudo wget https://raw.githubusercontent.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/master/Apache_2.2/custom.d/whitelist-domains.conf -O /etc/apache2/custom.d/whitelist-domains.conf
sudo wget https://raw.githubusercontent.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/master/Apache_2.2/custom.d/blacklist-ips.conf -O /etc/apache2/custom.d/blacklist-ips.conf
sudo wget https://raw.githubusercontent.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/master/Apache_2.2/custom.d/bad-referrer-words.conf -O /etc/apache2/custom.d/bad-referrer-words.conf
sudo wget https://raw.githubusercontent.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/master/Apache_2.2/custom.d/blacklist-user-agents.conf -O /etc/apache2/custom.d/blacklist-user-agents.conf

# **************
# Restart Apache
# **************

sudo service apache2 restart

# **********************
# Test the Apache Config
# **********************

sudo apache2ctl configtest

# *****************************************
# Get a copy of all conf files for checking
# *****************************************

sudo cp /etc/apache2/custom.d/*.conf $TRAVIS_BUILD_DIR/.dev-tools/_conf_files_2.2/
sudo cp /etc/apache2/apache2.conf $TRAVIS_BUILD_DIR/.dev-tools/_conf_files_2.2/apache2.conf
sudo cp /etc/apache2/sites-available/default.conf $TRAVIS_BUILD_DIR/.dev-tools/_conf_files_2.2/default.conf


# ***********************************************************
# Set all our other setup and deploy scripts to be executable
# ***********************************************************

sudo chmod +x $TRAVIS_BUILD_DIR/.dev-tools/deploy-package.sh
sudo chmod +x $TRAVIS_BUILD_DIR/.dev-tools/generate-blacklists.sh
sudo chmod +x $TRAVIS_BUILD_DIR/.dev-tools/generate-htaccess.php
sudo chmod +x $TRAVIS_BUILD_DIR/.dev-tools/generate-robots.sh
sudo chmod +x $TRAVIS_BUILD_DIR/.dev-tools/generate-google-disavow.sh
sudo chmod +x $TRAVIS_BUILD_DIR/.dev-tools/generate-google-exclude.php
sudo chmod +x $TRAVIS_BUILD_DIR/.dev-tools/apache-referers-regex.php
sudo chmod +x $TRAVIS_BUILD_DIR/.dev-tools/modify-readme.sh
sudo chmod +x $TRAVIS_BUILD_DIR/.dev-tools/modify-files-and-commit.sh
sudo chmod +x $TRAVIS_BUILD_DIR/.dev-tools/run-curl-tests-1.sh
sudo chmod +x $TRAVIS_BUILD_DIR/.dev-tools/run-curl-tests-2.sh
sudo chmod +x $TRAVIS_BUILD_DIR/.dev-tools/prepare-user-agents-htaccess.sh

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