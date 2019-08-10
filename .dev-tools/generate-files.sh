#!/bin/bash
# Travis CI Generating and Building for the Apache Ultimate Bad Bot Blocker
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


cd ${TRAVIS_BUILD_DIR}

# Fetch Latest Lists from Nginx REPO and Merge / Sort
# Merge and Sort Bad-Referrers
sudo wget https://raw.githubusercontent.com/mitchellkrogza/nginx-ultimate-bad-bot-blocker/master/_generator_lists/bad-referrers.list -O ${TRAVIS_BUILD_DIR}/_generator_lists/bad-referrers.nginx
cat ${TRAVIS_BUILD_DIR}/_generator_lists/bad-referrers.nginx >> ${TRAVIS_BUILD_DIR}/_generator_lists/bad-referrers.list
sort -u ${TRAVIS_BUILD_DIR}/_generator_lists/bad-referrers.list -o ${TRAVIS_BUILD_DIR}/_generator_lists/bad-referrers.list
sudo rm ${TRAVIS_BUILD_DIR}/_generator_lists/bad-referrers.nginx
# Merge and Sort Fake GoogleBots
sudo wget https://raw.githubusercontent.com/mitchellkrogza/nginx-ultimate-bad-bot-blocker/master/_generator_lists/fake-googlebots.list -O ${TRAVIS_BUILD_DIR}/_generator_lists/fake-googlebots.nginx
cat ${TRAVIS_BUILD_DIR}/_generator_lists/fake-googlebots.nginx >> ${TRAVIS_BUILD_DIR}/_generator_lists/fake-googlebots.list
sort -u ${TRAVIS_BUILD_DIR}/_generator_lists/fake-googlebots.list -o ${TRAVIS_BUILD_DIR}/_generator_lists/fake-googlebots.list
sudo rm ${TRAVIS_BUILD_DIR}/_generator_lists/fake-googlebots.nginx

# *****************************************************
# Generate our files with build and version information
# *****************************************************

sudo ${TRAVIS_BUILD_DIR}/.dev-tools/prepare-user-agents-htaccess.sh
php ./.dev-tools/apache-referers-regex.php
php ./.dev-tools/generate-htaccess.php
php ./.dev-tools/generate-google-exclude.php
sudo ${TRAVIS_BUILD_DIR}/.dev-tools/generate-robots.sh
sudo ${TRAVIS_BUILD_DIR}/.dev-tools/generate-google-disavow.sh
sudo ${TRAVIS_BUILD_DIR}/.dev-tools/generate-blacklists.sh
sudo ${TRAVIS_BUILD_DIR}/.dev-tools/modify-readme.sh

# **********************
# Exit With Error Number
# **********************

exit ${?}

