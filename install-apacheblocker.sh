#!/bin/bash
# Bash Script for Installing the Apache Bad Bot Blocker for Apache 2.2 > 2.4
# Copyright - https://github.com/mitchellkrogza
# Project Url: https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker

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

# Please Note:
# ************
# This script will install Apache 2.2 or 2.4 configurations.
# If you attempt to use Apache 2.2 configs wiht Apache 2.4 you will need the mod_access_compat module to be loaded.
# The new Apache 2.4 version uses the new Apache Access Control methods and does not require the mod_access_compat module to be loaded in order to work.

# PLEASE READ CONFIGURATION INSTRUCTIONS BEFORE USING THIS - THIS IS ONLY A PARTIAL INSTALLER
# https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/blob/master/CONFIGURATION.md

# Use this script only once and thereafter use the Auto Update Bash Script update-apacheblocker.sh

# THIS INSTALL SCRIPT ONLY COPIES THE NECESSARY FILES FOR APACHE DIRECT FROM THE REPO

### You must manually edit any vhost files with the required include or it will not actually be protecting any sites.
### READ: https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/blob/master/CONFIGURATION.md

# Save this file as ~/install-apacheblocker.sh
# sudo wget https://raw.githubusercontent.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/master/install-apacheblocker.sh -O ~/install-apacheblocker.sh
# Make it Executable chmod +x ~/install-apacheblocker.sh
# Run it from the command line using sudo ~/install-apacheblocker.sh

#Update all environment variables to suit your OS/Apache version.

# LETS INSTALL NOW

#Major Apache version e.g. 2.2, 2.4
APACHE_VERSION='2.4'
#Directory where bad bot configs are located.
#Generally /etc/apache2 or /etc/httpd depending on OS
APACHE_CONF='/etc/apache2'
#location of Apache blocker files
BLOCKER_URL="https://raw.githubusercontent.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/master/Apache_${APACHE_VERSION}/custom.d"

sudo mkdir -p "${APACHE_CONF}/custom.d"
sudo wget ${BLOCKER_URL}/globalblacklist.conf -O "${APACHE_CONF}/custom.d/globalblacklist.conf"
sudo wget ${BLOCKER_URL}/whitelist-ips.conf -O "${APACHE_CONF}/custom.d/whitelist-ips.conf"
sudo wget ${BLOCKER_URL}/whitelist-domains.conf -O "${APACHE_CONF}/custom.d/whitelist-domains.conf"
sudo wget ${BLOCKER_URL}/blacklist-ips.conf -O "${APACHE_CONF}/custom.d/blacklist-ips.conf"
sudo wget ${BLOCKER_URL}/bad-referrer-words.conf -O "${APACHE_CONF}/custom.d/bad-referrer-words.conf"
sudo wget ${BLOCKER_URL}/blacklist-user-agents.conf -O "${APACHE_CONF}/custom.d/blacklist-user-agents.conf"
echo "Manually edit vhost to include globalblacklist.conf"
exit 0

# PLEASE READ CONFIGURATION INSTRUCTIONS
# https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/blob/master/CONFIGURATION.md

