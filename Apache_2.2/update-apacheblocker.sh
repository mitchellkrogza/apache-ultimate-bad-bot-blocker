#!/bin/bash
# Bash Script for Auto Updating the Apache Bad Bot Blocker for Apache 2.2 > 2.4
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

# MAKE SURE you have your whitelist-ips.conf, whitelist-domains.conf, blacklist-ips.conf and bad-referrer-words.conf files in /etc/custom.d
# A major change to using include files was introduced in
# https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/releases/tag/2017-04-19.Build-173

# PLEASE READ UPDATED CONFIGURATION INSTRUCTIONS BEFORE USING THIS

# Save this file as /usr/sbin/update-apacheblocker.sh
# Make it Executable chmod +x /usr/sbin/updateapacheblocker.sh

# RUN THE UPDATE
# Here our script runs, pulls the latest update, reloads apache and emails you a notification
# Place your own valid email address where it says "me@myemail.com"
 
sudo wget https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/raw/master/Apache_2.2/custom.d/globalblacklist.conf -O /etc/custom.d/globalblacklist.conf
sudo service apache2 reload | mail -s "Apache Bad Bot Blocker Updated" me@myemail.com
exit 0

# Add this as a cron to run daily / weekly as you like
# Here's a sample CRON entry to update every day at 10pm
# 00 22 * * * /usr/sbin/update-apacheblocker.sh
