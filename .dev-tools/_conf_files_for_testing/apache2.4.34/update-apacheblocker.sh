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
# Make it Executable chmod +x /usr/sbin/update-apacheblocker.sh

# RUN THE UPDATE
# Here our script runs, pulls the latest update, runs a config test then reloads apache and emails you a notification
# Place your own valid email address where it says "me@myemail.com"

#Update all environment variables to suit your OS/Apache version.

#Major Apache version e.g. 2.2, 2.4
APACHE_VERSION='2.4'
#Directory where bad bot configs are located.
APACHE_CONF='/etc/apache2/custom.d'
#location of globalblacklist
BLACKLIST_URL="https://raw.githubusercontent.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/master/Apache_${APACHE_VERSION}/custom.d/globalblacklist.conf"
#Address to send update notifications
EMAIL='mitchellkrog@gmail.com'
#Make backup of globalblacklist.conf when updating true or false.
MAKE_BACKUP=false
#Run apachectl test before reload true/false
TEST_BEFORE_RELOAD=true
#Curl test to ensure blocking still working after reload true/false.
CURL_TEST_AFTER_RELOAD=true
#Specify if your site uses http or https
CURL_TEST_PROTOCOL=http
#domain name to test against.
CURL_TEST_URL_NAME=localhost

SERVER_NAME=$(hostname)
UPDATE_FAIL="Bad bot failed to update globalblacklist on ${SERVER_NAME}"
UPDATE_SUCCESS="Bad bot globalblacklist successfully updated on ${SERVER_NAME}"
CURL_FAIL="Bad bot curl tests have failed on ${SERVER_NAME}."
WGET_FAIL="Unable to obtain updated globalblacklist. Wget failed on ${SERVER_NAME}."
CONF_ERROR="Bad bot globalblacklist not present. Does not appear to be setup properly. Aborting update on ${SERVER_NAME}"
DATE=$(date +%Y-%m-%d-%H-%M-%S)

if [ ! -f ${APACHE_CONF}/globalblacklist.conf ] ; then
  #Aborting update
  echo -e "Subject: Bad bot not installed properly \\n\\n ${CONF_ERROR}\\n" | sendmail -t ${EMAIL};
  exit 1;
else
  diff <(wget -q -O - ${BLACKLIST_URL}) ${APACHE_CONF}/globalblacklist.conf;
  DIFF_CHECK=$?
  if [ ${DIFF_CHECK} -eq 0 ] ; then
    #Nothing changed
    echo "Bad bot globalblacklist is already up to date";
    exit 0;
  else
    if [ ${MAKE_BACKUP} = true ] ; then
      cp "${APACHE_CONF}/globalblacklist.conf" "${APACHE_CONF}/globalblacklist.${DATE}.backup";
      # Delete backups that are older than 5 days
      find ${APACHE_CONF} -maxdepth 1 -type f -mtime +5 -name 'globalblacklist.*.backup' -exec rm {} \;
    fi
    wget ${BLACKLIST_URL} -O ${APACHE_CONF}/globalblacklist.tmp && mv ${APACHE_CONF}/globalblacklist.tmp ${APACHE_CONF}/globalblacklist.conf;
    if [ -f ${APACHE_CONF}/globalblacklist.tmp ] ; then
      echo -e "Subject: Bad bot update WGET FAIL \\n\\n ${WGET_FAIL}\\n" | sendmail -t ${EMAIL};
      rm -f ${APACHE_CONF}/globalblacklist.tmp;
      exit 1;
    fi
    if [ ${TEST_BEFORE_RELOAD} = true ] ; then
      apachectl configtest || TESTFAIL=true;
    fi
    if [ -z ${TESTFAIL} ] ; then
      apachectl graceful;
      if [ ${CURL_TEST_AFTER_RELOAD} = true ] ; then
        CURL_RESPONSE_BAD=$(curl -A "masscan" -Isk -o /dev/null -w %{http_code} ${CURL_TEST_PROTOCOL}://${CURL_TEST_URL_NAME} | tr -dc '[:alnum:]')
        CURL_RESPONSE_GOOD=$(curl -A "googlebot" -Isk -o /dev/null -w %{http_code} ${CURL_TEST_PROTOCOL}://${CURL_TEST_URL_NAME} | tr -dc '[:alnum:]')
        if [ $CURL_RESPONSE_BAD != "403" ] || [ $CURL_RESPONSE_GOOD != "200" ] ; then
          echo -e "Subject: Bad bot CURL FAIL \\n\\n ${CURL_FAIL}\\n" | sendmail -t ${EMAIL};
          exit 1;
        fi
      fi
      echo -e "Subject: Bad bot updated globalblacklist \\n\\n ${UPDATE_SUCCESS}\\n" | sendmail -t ${EMAIL};
      exit 0;
    else
      echo -e "Subject: Bad bot update FAIL \\n\\n ${UPDATE_FAIL}\\n" | sendmail -t ${EMAIL};
      exit 1;
    fi
  fi
fi

# Add this as a cron to run daily / weekly as you like
# Here's a sample CRON entry to update every day at 10pm
# 00 22 * * * /usr/sbin/update-apacheblocker.sh
