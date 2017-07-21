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

# Install Apache2
sudo apt-get update
sudo apt-get install -y --force-yes apache2

# Copy our virtual host template to sites-enabled overwriting the default site conf
sudo cp $TRAVIS_BUILD_DIR/.dev-tools/defaultsite.conf /etc/apache2/sites-available/000-default.conf

# Copy basic testing files into /var/www
sudo cp $TRAVIS_BUILD_DIR/.dev-tools/index.html /var/www/index.html

# Enable mod rewrite module
sudo a2enmod rewrite

# Enable Default Site
sudo a2ensite 000-default.conf

# Set ServerName Globally
sudo cp $TRAVIS_BUILD_DIR/.dev-tools/servername.conf /etc/apache2/conf-available/servername.conf

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
sudo a2enconf servername

# **************
# Restart Apache
# **************

sudo service apache2 restart

# **********************
# Test the Apache Config
# **********************

sudo apache2ctl configtest

# ***********************************************************
# Set all our other setup and deploy scripts to be executable
# ***********************************************************

sudo chmod +x $TRAVIS_BUILD_DIR/.dev-tools/deploy-package.sh
sudo chmod +x $TRAVIS_BUILD_DIR/.dev-tools/generate-blacklist-2.2.sh
sudo chmod +x $TRAVIS_BUILD_DIR/.dev-tools/generate-blacklist24.sh
sudo chmod +x $TRAVIS_BUILD_DIR/.dev-tools/generate-htaccess.php
sudo chmod +x $TRAVIS_BUILD_DIR/.dev-tools/generate-robots.sh
sudo chmod +x $TRAVIS_BUILD_DIR/.dev-tools/generate-google-disavow.sh
sudo chmod +x $TRAVIS_BUILD_DIR/.dev-tools/generate-google-exclude.php
sudo chmod +x $TRAVIS_BUILD_DIR/.dev-tools/apache-referers-regex.php
sudo chmod +x $TRAVIS_BUILD_DIR/.dev-tools/modify-readme.sh
sudo chmod +x $TRAVIS_BUILD_DIR/.dev-tools/modify-files-and-commit.sh
sudo chmod +x $TRAVIS_BUILD_DIR/.dev-tools/run-curl-tests.sh
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