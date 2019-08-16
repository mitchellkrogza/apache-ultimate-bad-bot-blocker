#!/bin/bash
# Setup Apache for Testing the Apache Ultimate Bad Bot Blocker on apache 2.2.25
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

# ---------
# FUNCTIONS
# ---------

spinner()
{
  local DURATION=$1
  local INT=0.25      # refresh interval

  local TIME=0
  local CURLEN=0
  local SECS=0
  local FRACTION=0

  local FB=2588       # full block

  trap "echo -e $(tput cnorm); trap - SIGINT; return" SIGINT

  echo -ne "$(tput civis)\r$(tput el)│"                # clean line

  local START=$( date +%s%N )

  while [ $SECS -lt $DURATION ]; do
    local COLS=$( tput cols )

    # main bar
    local L=$( bc -l <<< "( ( $COLS - 5 ) * $TIME  ) / ($DURATION-$INT)" | awk '{ printf "%f", $0 }' )
    local N=$( bc -l <<< $L                                              | awk '{ printf "%d", $0 }' )

    [ $FRACTION -ne 0 ] && echo -ne "$( tput cub 1 )"  # erase partial block

    if [ $N -gt $CURLEN ]; then
      for i in $( seq 1 $(( N - CURLEN )) ); do
        echo -ne \\u$FB
      done
      CURLEN=$N
    fi

    # partial block adjustment
    FRACTION=$( bc -l <<< "( $L - $N ) * 8" | awk '{ printf "%.0f", $0 }' )

    if [ $FRACTION -ne 0 ]; then
      local PB=$( printf %x $(( 0x258F - FRACTION + 1 )) )
      echo -ne \\u$PB
    fi

    # percentage progress
    local PROGRESS=$( bc -l <<< "( 100 * $TIME ) / ($DURATION-$INT)" | awk '{ printf "%.0f", $0 }' )
    echo -ne "$( tput sc )"                            # save pos
    echo -ne "\r$( tput cuf $(( COLS - 6 )) )"         # move cur
    echo -ne "│ $PROGRESS%"
    echo -ne "$( tput rc )"                            # restore pos

    TIME=$( bc -l <<< "$TIME + $INT" | awk '{ printf "%f", $0 }' )
    SECS=$( bc -l <<<  $TIME         | awk '{ printf "%d", $0 }' )

    # take into account loop execution time
    local END=$( date +%s%N )
    local DELTA=$( bc -l <<< "$INT - ( $END - $START )/1000000000" \
                   | awk '{ if ( $0 > 0 ) printf "%f", $0; else print "0" }' )
    sleep $DELTA
    START=$( date +%s%N )
  done

  echo $(tput cnorm)
  trap - SIGINT
}


# **************************************
# Make sure no other Apache is Installed
# **************************************

sudo apt-get remove --purge apache2

# *************************************************************
# Make sure We Have Build Essentials for Building apache 2.2.25
# *************************************************************

sudo apt-get install build-essential

# ************************
# Lets Build Apache 2.2.25
# ************************
# With Thanks to https://serverfault.com/users/385523/johano-fierra
# REF: https://serverfault.com/questions/544779/how-can-i-install-apache-with-a-specific-version
# **********************************************************************************************

cd /tmp

wget http://www.zlib.net/zlib-1.2.11.tar.gz
tar -xvf zlib-1.2.11.tar.gz > /dev/null
cd zlib-1.2.11/
./configure --prefix=/usr/local >/dev/null
echo "${bold}${green}Building zlib"
printf '\n'
make &> zlib.log &
spinner 30
echo "${bold}${green}Installing zlib"
printf '\n'
sudo make -s install &> zlib.log &
spinner 30

wget https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/raw/master/.dev-tools/_apache_builds/httpd-2.2.25.tar.gz
tar -xvf httpd-2.2.25.tar.gz > /dev/null
cd httpd-2.2.25/
./configure --prefix=/usr/local/apache2 --enable-mods-shared=all --enable-deflate --enable-proxy --enable-proxy-balancer --enable-proxy-http >/dev/null
echo "${bold}${green}Building Apache 2.2.25"
printf '\n'
make &> apache2build.log &
spinner 60
echo "${bold}${green}Installing Apache 2.2.25"
printf '\n'
sudo make -s install &> apache2build.log &
spinner 30

${defaultcolor}
sudo /usr/local/apache2/bin/apachectl start

wget -qO- http://localhost | grep "It works!"

# *********************************
# Prepare Apache 2.2.25 For Testing
# *****************************************************
# Copy basic testing index.html file into /var/www/html
# *****************************************************

sudo mkdir /var/www
sudo mkdir /var/www/html
sudo cp ${TRAVIS_BUILD_DIR}/.dev-tools/index.html /var/www/html/index.html

# *************************
# Set Ownership of /var/www
# *************************

sudo chown -R www-data:www-data /var/www/

# **************************
# Show Loaded apache Modules
# **************************

echo "${bold}${green}Show Loaded Apache Modules"
sudo /usr/local/apache2/bin/apachectl -M

# **************************
# Show Apache Version
# **************************

echo "${bold}${green}Show Apache Version Information"
sudo /usr/local/apache2/bin/apachectl -V

# *****************************
# Put new httpd.conf into place
# *****************************

echo "${bold}${yellow}Copy httpd.conf"
sudo cp ${TRAVIS_BUILD_DIR}/.dev-tools/_conf_files_for_testing/apache2.2.25/httpd.conf /usr/local/apache2/conf/httpd.conf

# ************************************
# Put new httpd-vhosts.conf into place
# ************************************

echo "${bold}${yellow}Copy httpd-vhosts.conf"
sudo cp ${TRAVIS_BUILD_DIR}/.dev-tools/_conf_files_for_testing/apache2.2.25/httpd-vhosts.conf /usr/local/apache2/conf/extra/httpd-vhosts.conf

# *************************************
# Get files from Repo Apache_2.2
# *************************************

echo "${bold}${yellow}Get blocker files from repo"
sudo mkdir /usr/local/apache2/custom.d
sudo wget https://raw.githubusercontent.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/master/Apache_2.2/custom.d/globalblacklist.conf -O /usr/local/apache2/custom.d/globalblacklist.conf
sudo wget https://raw.githubusercontent.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/master/Apache_2.2/custom.d/whitelist-ips.conf -O /usr/local/apache2/custom.d/whitelist-ips.conf
sudo wget https://raw.githubusercontent.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/master/Apache_2.2/custom.d/whitelist-domains.conf -O /usr/local/apache2/custom.d/whitelist-domains.conf
sudo wget https://raw.githubusercontent.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/master/Apache_2.2/custom.d/blacklist-ips.conf -O /usr/local/apache2/custom.d/blacklist-ips.conf
sudo wget https://raw.githubusercontent.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/master/Apache_2.2/custom.d/bad-referrer-words.conf -O /usr/local/apache2/custom.d/bad-referrer-words.conf
sudo wget https://raw.githubusercontent.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/master/Apache_2.2/custom.d/blacklist-user-agents.conf -O /usr/local/apache2/custom.d/blacklist-user-agents.conf

# **********************
# Test the Apache Config
# **********************

echo "${bold}${green}Run Apache 2.2 Config Test"
sudo /usr/local/apache2/bin/apachectl configtest

# *********************
# Restart Apache 2.2.25
# *********************

echo "${bold}${yellow}Restarting Apache 2.2"
sudo /usr/local/apache2/bin/apachectl restart

# ******************
# Test Apache 2 Curl
# ******************

echo "${bold}${yellow}Test wget"
wget -qO- http://local.dev

# ********************************************************************
# Place an older globalblacklist.conf into place to test update script
# ********************************************************************

echo "${bold}${yellow}Install old version of blacklist to test updater"
sudo cp ${TRAVIS_BUILD_DIR}/.dev-tools/_conf_files_for_testing/apache2.2.25/old-globalblacklist.conf /usr/local/apache2/custom.d/globalblacklist.conf

# *****************************
# Download and test the updater
# *****************************

echo "${bold}${yellow}Download update-apacheblocker.sh"
sudo wget https://raw.githubusercontent.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/master/update-apacheblocker.sh -O ${TRAVIS_BUILD_DIR}/.dev-tools/_conf_files_for_testing/apache2.2.25/update-apacheblocker.sh
sed -n "s/2\.4/2\.2/g" ${TRAVIS_BUILD_DIR}/.dev-tools/_conf_files_for_testing/apache2.2.25/update-apacheblocker.sh > ${TRAVIS_BUILD_DIR}/.dev-tools/_conf_files_for_testing/apache2.2.25/update-apacheblocker.tmp && sudo mv ${TRAVIS_BUILD_DIR}/.dev-tools/_conf_files_for_testing/apache2.2.25/update-apacheblocker.tmp ${TRAVIS_BUILD_DIR}/.dev-tools/_conf_files_for_testing/apache2.2.25/update-apacheblocker.sh
sed -n "s/email@example.com/mitchellkrog@gmail.com/g" ${TRAVIS_BUILD_DIR}/.dev-tools/_conf_files_for_testing/apache2.2.25/update-apacheblocker.sh > ${TRAVIS_BUILD_DIR}/.dev-tools/_conf_files_for_testing/apache2.2.25/update-apacheblocker.tmp && sudo mv ${TRAVIS_BUILD_DIR}/.dev-tools/_conf_files_for_testing/apache2.2.25/update-apacheblocker.tmp ${TRAVIS_BUILD_DIR}/.dev-tools/_conf_files_for_testing/apache2.2.25/update-apacheblocker.sh
sed -n "s/\/etc\/apache2\/custom.d/\/usr\/local\/apache2\/custom.d/g" ${TRAVIS_BUILD_DIR}/.dev-tools/_conf_files_for_testing/apache2.2.25/update-apacheblocker.sh > ${TRAVIS_BUILD_DIR}/.dev-tools/_conf_files_for_testing/apache2.2.25/update-apacheblocker.tmp && sudo mv ${TRAVIS_BUILD_DIR}/.dev-tools/_conf_files_for_testing/apache2.2.25/update-apacheblocker.tmp ${TRAVIS_BUILD_DIR}/.dev-tools/_conf_files_for_testing/apache2.2.25/update-apacheblocker.sh
sed -n "s/apachectl/\/usr\/local\/apache2\/bin\/apachectl/g" ${TRAVIS_BUILD_DIR}/.dev-tools/_conf_files_for_testing/apache2.2.25/update-apacheblocker.sh > ${TRAVIS_BUILD_DIR}/.dev-tools/_conf_files_for_testing/apache2.2.25/update-apacheblocker.tmp && sudo mv ${TRAVIS_BUILD_DIR}/.dev-tools/_conf_files_for_testing/apache2.2.25/update-apacheblocker.tmp ${TRAVIS_BUILD_DIR}/.dev-tools/_conf_files_for_testing/apache2.2.25/update-apacheblocker.sh
echo "${bold}${yellow}Test update-apacheblocker.sh"
sudo chmod +x ${TRAVIS_BUILD_DIR}/.dev-tools/_conf_files_for_testing/apache2.2.25/update-apacheblocker.sh
sudo bash ${TRAVIS_BUILD_DIR}/.dev-tools/_conf_files_for_testing/apache2.2.25/update-apacheblocker.sh

# ***********************************************************************************
# Put Latest Generated globalblacklist.conf into place for correct testing of changes
# ***********************************************************************************

echo "${bold}${yellow}Place latest generated version of globalblacklist.conf into place"
sudo cp /home/travis/build/mitchellkrogza/apache-ultimate-bad-bot-blocker/Apache_2.2/custom.d/globalblacklist.conf /usr/local/apache2/custom.d/globalblacklist.conf
echo "${bold}${yellow}Restarting Apache 2.2"
sudo /usr/local/apache2/bin/apachectl restart

# *****************************************
# Get a copy of all conf files for checking
# *****************************************

echo "${bold}${yellow}Backup Config Files"
sudo cp /usr/local/apache2/custom.d/*.conf ${TRAVIS_BUILD_DIR}/.dev-tools/_test_results/_conf_files_2.2/
sudo cp /usr/local/apache2/conf/httpd.conf ${TRAVIS_BUILD_DIR}/.dev-tools/_test_results/_conf_files_2.2/httpd.conf
sudo cp /usr/local/apache2/conf/extra/httpd-vhosts.conf ${TRAVIS_BUILD_DIR}/.dev-tools/_test_results/_conf_files_2.2/

# ************************************************
# Exit With Error Number and Continue to Run Tests
# ************************************************

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
