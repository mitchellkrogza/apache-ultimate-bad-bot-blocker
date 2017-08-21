#!/bin/bash
# Bash Script for Installing the Apache Bad Bot Blocker
# Copyright - https://github.com/mitchellkrogza
# Project Url: https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker

# *************************************************
# SOON TO DEPRECATED
# PLEASE REFER TO Apache_2.2 and Apache_2.4 Folders
# *************************************************

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
 
cd /etc/apache2/custom.d
sudo wget https://raw.githubusercontent.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/master/custom.d/globalblacklist.conf -O globalblacklist.conf
sudo wget https://raw.githubusercontent.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/master/custom.d/whitelist-ips.conf -O whitelist-ips.conf
sudo wget https://raw.githubusercontent.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/master/custom.d/whitelist-domains.conf -O whitelist-domains.conf
sudo wget https://raw.githubusercontent.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/master/custom.d/blacklist-ips.conf -O blacklist-ips.conf
sudo wget https://raw.githubusercontent.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/master/custom.d/bad-referrer-words.conf -O bad-referrer-words.conf
sudo wget https://raw.githubusercontent.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/master/custom.d/blacklist-user-agents.conf -O blacklist-user-agents.conf
exit 0

# PLEASE READ CONFIGURATION INSTRUCTIONS
# https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/blob/master/CONFIGURATION.md

