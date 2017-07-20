#!/bin/bash
# Bash Script for Installing the Apache Bad Bot Blocker for Apache 2.2 > 2.4
# Copyright - https://github.com/mitchellkrogza
# Project Url: https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker

# Please Note:
# ************
# This version will work on Apache 2.2 > 2.4+ but on Apache 2.4+ it requires the mod_access_compat module
# to be loaded. The new Apache 2.4 version uses the new Apache Access Control methods and does not require
# the mod_access_compat module to be loaded in order to work.

# PLEASE READ CONFIGURATION INSTRUCTIONS BEFORE USING THIS - THIS IS ONLY A PARTIAL INSTALLER
# https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/blob/master/CONFIGURATION.md

# Use this script only once and thereafter use the Auto Update Bash Script update-apacheblocker.sh

# THIS INSTALL SCRIPT ONLY COPIES THE NECESSARY FILES FOR APACHE DIRECT FROM THE REPO

### You must manually edit any vhost files with the required include or it will not actually be protecting any sites.
### READ: https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/blob/master/CONFIGURATION.md

# Save this file as /usr/sbin/install-apacheblocker.sh
# sudo wget https://raw.githubusercontent.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/master/install-apacheblocker.sh -O install-apacheblocker.sh
# Make it Executable chmod +x /usr/sbin/install-apacheblocker.sh
# Run it from the command line using sudo /usr/sbin/install-apacheblocker.sh

# LETS INSTALL NOW
 
sudo mkdir /etc/apache2/custom.d
sudo wget https://raw.githubusercontent.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/master/Apache_2.2/custom.d/globalblacklist.conf -O /etc/apache2/custom.d/globalblacklist.conf
sudo wget https://raw.githubusercontent.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/master/Apache_2.2/custom.d/whitelist-ips.conf -O /etc/apache2/custom.d/whitelist-ips.conf
sudo wget https://raw.githubusercontent.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/master/Apache_2.2/custom.d/whitelist-domains.conf -O /etc/apache2/custom.d/whitelist-domains.conf
sudo wget https://raw.githubusercontent.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/master/Apache_2.2/custom.d/blacklist-ips.conf -O /etc/apache2/custom.d/blacklist-ips.conf
sudo wget https://raw.githubusercontent.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/master/Apache_2.2/custom.d/bad-referrer-words.conf -O /etc/apache2/custom.d/bad-referrer-words.conf
sudo wget https://raw.githubusercontent.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/master/Apache_2.2/custom.d/blacklist-user-agents.conf -O /etc/apache2/custom.d/blacklist-user-agents.conf
exit 0

# PLEASE READ CONFIGURATION INSTRUCTIONS
# https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/blob/master/CONFIGURATION.md

