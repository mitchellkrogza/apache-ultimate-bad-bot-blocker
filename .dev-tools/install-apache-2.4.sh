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

# ************************
# Lets Build Apache 2.4.34
# ************************

cd /tmp

wget http://www.zlib.net/zlib-1.2.11.tar.gz
tar -xvf zlib-1.2.11.tar.gz
cd zlib-1.2.11/
./configure --prefix=/usr/local
make
sudo make install

wget https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/raw/master/.dev-tools/_apache_builds/httpd-2.4.34.tar.gz
tar -xvf httpd-2.4.34.tar.gz
cd httpd-2.4.34/
./configure --prefix=/usr/local/apache2 --enable-mods-shared=all --enable-deflate --enable-proxy --enable-proxy-balancer --enable-proxy-http
make
sudo make install

sudo /usr/local/apache2/bin/apachectl start

wget -qO- http://localhost | grep "It works!"

# *********************************
# Prepare Apache 2.2.25 For Testing
# *****************************************************
# Copy basic testing index.html file into /var/www/html
# *****************************************************

#sudo mkdir /var/www
#sudo mkdir /var/www/html
#sudo cp ${TRAVIS_BUILD_DIR}/.dev-tools/index.html /var/www/html/index.html

# *************************
# Set Ownership of /var/www
# *************************

#sudo chown -R www-data:www-data /var/www/

# **************************
# Show Loaded apache Modules
# **************************

printf '%s\n%s\n%s\n\n' "#################################" "Show Loaded Apache Modules" "#################################"
sudo /usr/local/apache2/bin/apachectl -M

# **************************
# Show Apache Version
# **************************

printf '%s\n%s\n%s\n\n' "#####################################" "Show Apache Version Information" "#####################################"
sudo /usr/local/apache2/bin/apachectl -V

# *****************************
# Put new httpd.conf into place
# *****************************
#echo "Copy httpd.conf"
#sudo cp ${TRAVIS_BUILD_DIR}/.dev-tools/_conf_files_for_testing/apache2.2.25/httpd.conf /usr/local/apache2/conf/httpd.conf

# Get copy of httpd.conf for 2.4
sudo cp /usr/local/apache2/conf/httpd.conf ${TRAVIS_BUILD_DIR}/.dev-tools/_conf_files_for_testing/apache2.4.34/httpd.conf

# Get copy of httpd-vhosts.conf for 2.4
sudo cp /usr/local/apache2/conf/extra/httpd-vhosts.conf ${TRAVIS_BUILD_DIR}/.dev-tools/_conf_files_for_testing/apache2.4.34/httpd-vhosts.conf


# ************************************
# Put new httpd-vhosts.conf into place
# ************************************
#echo "Copy httpd-vhosts.conf"
#sudo cp ${TRAVIS_BUILD_DIR}/.dev-tools/_conf_files_for_testing/apache2.2.25/httpd-vhosts.conf /usr/local/apache2/conf/extra/httpd-vhosts.conf

# *************************************
# Get files from Repo Apache_2.4
# *************************************

#sudo mkdir /etc/apache2/custom.d
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
sudo /usr/local/apache2/bin/apachectl configtest

# *********************
# Restart Apache 2.2.25
# *********************

echo "Restarting Apache 2.2"
sudo /usr/local/apache2/bin/apachectl restart

# ******************
# Test Apache 2 Curl
# ******************

wget -qO- http://local.dev

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