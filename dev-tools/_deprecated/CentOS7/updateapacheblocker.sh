#!/bin/bash
# Bash Script for Auto Updating the Apache Bad Bot Blocker for CentOS 6.8 / Apache 2.2.15
# Copyright - https://github.com/mitchellkrogza
# Project Url: https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/CentOS6/

# MAKE SURE you have your whitelist-ips.conf and whitelist-domains.conf files in /etc/httpd/conf/conf.d
# A major change to using include files was introduced in
# https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/commit/4e9fbb6110e0d43eb1fa198eac9dd22b13cc96aaf

# PLEASE READ UPDATED CONFIGURATION INSTRUCTIONS BEFORE USING THIS

# Save this file as /bin/updateapacheblocker.sh
# Make it Executable chmod +x /bin/updateapacheblocker.sh

# RUN THE UPDATE
# Here our script runs, pulls the latest update, reloads apache and emails you a notification
# Place your own valid email address where it says "me@myemail.com"

# Add your username to the sudoers file
# nano /etc/sudoers
# Add this line
# yourusername ALL=(ALL)  ALL
 
cd /etc/httpd/custom.d
sudo wget https://raw.githubusercontent.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/master/CentOS6/conf.d/globalblacklist.conf -O globalblacklist.conf
sudo service httpd reload | mail -s "Apache Bad Bot Blocker Updated" me@myemail.com
exit 0

# Add this as a cron to run daily / weekly as you like
# Here's a sample CRON entry to update every day at 10pm
# 00 22 * * * /bin/updateapacheblocker.sh