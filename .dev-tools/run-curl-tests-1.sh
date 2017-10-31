#!/bin/bash
# Curl Testing Script for Apache Ultimate Bad Bot Blocker
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

# *******************************************
# Set Location of our Curl Test Results Files
# *******************************************

_curltest1=$TRAVIS_BUILD_DIR/.dev-tools/_curl_tests/curltest1.txt
_curltest2=$TRAVIS_BUILD_DIR/.dev-tools/_curl_tests/curltest2.txt
_curltest3=$TRAVIS_BUILD_DIR/.dev-tools/_curl_tests/curltest3.txt
_curltest4=$TRAVIS_BUILD_DIR/.dev-tools/_curl_tests/curltest4.txt
_curltest5=$TRAVIS_BUILD_DIR/.dev-tools/_curl_tests/curltest5.txt
_curltest6=$TRAVIS_BUILD_DIR/.dev-tools/_curl_tests/curltest6.txt
_curltest7=$TRAVIS_BUILD_DIR/.dev-tools/_curl_tests/curltest7.txt
_curltest8=$TRAVIS_BUILD_DIR/.dev-tools/_curl_tests/curltest8.txt
_curltest9=$TRAVIS_BUILD_DIR/.dev-tools/_curl_tests/curltest9.txt
_curltest10=$TRAVIS_BUILD_DIR/.dev-tools/_curl_tests/curltest10.txt
_curltest11=$TRAVIS_BUILD_DIR/.dev-tools/_curl_tests/curltest11.txt

_now="$(date)"

# *************************************************
# Function Curl Test 1 - Check for Bad Bot "80legs"
# *************************************************

run_curltest1 () {
truncate -s 0 $_curltest1
printf '%s%s\n\n' "Last Tested: " "$_now" >> "$_curltest1"
curl -A "80legs" http://local.dev:80/index.html 2>&1 >> $_curltest1
if grep -i 'Forbidden' $_curltest1; then
   echo 'BAD BOT DETECTED - TEST PASSED'
else
   echo 'BAD BOT NOT DETECTED - TEST FAILED'
   exit 1
fi
}

# **************************************************
# Function Curl Test 2 - Check for Bad Bot "masscan"
# **************************************************

run_curltest2 () {
truncate -s 0 $_curltest2
printf '%s%s\n\n' "Last Tested: " "$_now" >> "$_curltest2"
curl -A "masscan" http://local.dev:80/index.html 2>&1 >> $_curltest2
if grep -i 'Forbidden' $_curltest2; then
   echo 'BAD BOT DETECTED - TEST PASSED'
else
   echo 'BAD BOT NOT DETECTED - TEST FAILED'
   exit 1
fi
}

# ******************************************************************
# Function Curl Test 3 - Check for Bad Referrer "100dollars-seo.com"
# ******************************************************************

run_curltest3 () {
truncate -s 0 $_curltest3
printf '%s%s\n\n' "Last Tested: " "$_now" >> "$_curltest3"
curl -I http://local.dev:80/index.html -e http://100dollars-seo.com 2>&1 >> $_curltest3
if grep -i 'Forbidden' $_curltest3; then
   echo 'BAD REFERRER DETECTED - TEST PASSED'
else
   echo 'BAD REFERRER NOT DETECTED - TEST FAILED'
   exit 1
fi
}

# ******************************************************
# Function Curl Test 4 - Check for Bad Referrer "zx6.ru"
# ******************************************************

run_curltest4 () {
truncate -s 0 $_curltest4
printf '%s%s\n\n' "Last Tested: " "$_now" >> "$_curltest4"
curl -I http://local.dev:80/index.html -e http://zx6.ru 2>&1 >> $_curltest4
if grep -i 'Forbidden' $_curltest4; then
   echo 'BAD REFERRER DETECTED - TEST PASSED'
else
   echo 'BAD REFERRER NOT DETECTED - TEST FAILED'
   exit 1
fi
}

# *****************************************************
# Function Curl Test 5 - Check for Good Bot "GoogleBot"
# *****************************************************

run_curltest5 () {
truncate -s 0 $_curltest5
printf '%s%s\n\n' "Last Tested: " "$_now" >> "$_curltest5"
curl -v -A "GoogleBot" http://local.dev:80/index.html 2>&1 >> $_curltest5
if grep -i 'Welcome' $_curltest5; then
   echo 'GOOD BOT ALLOWED THROUGH - TEST PASSED'
else
   echo 'GOOD BOT NOT ALLOWED THROUGH - TEST FAILED'
   exit 1
fi
}

# ***************************************************
# Function Curl Test 6 - Check for Good Bot "BingBot"
# ***************************************************

run_curltest6 () {
truncate -s 0 $_curltest6
printf '%s%s\n\n' "Last Tested: " "$_now" >> "$_curltest6"
curl -v -A "BingBot" http://local.dev:80/index.html 2>&1 >> $_curltest6
if grep -i 'Welcome' $_curltest6; then
   echo 'GOOD BOT ALLOWED THROUGH - TEST PASSED'
else
   echo 'GOOD BOT NOT ALLOWED THROUGH - TEST FAILED'
   exit 1
fi
}


# **************************************************
# Function Curl Test 7 - Check for Bad Bot "Disco"
# **************************************************

run_curltest7 () {
truncate -s 0 $_curltest7
printf '%s%s\n\n' "Last Tested: " "$_now" >> "$_curltest7"
curl -A "Disco" http://local.dev:80/index.html 2>&1 >> $_curltest7
if grep -i 'Forbidden' $_curltest7; then
   echo 'BAD BOT DETECTED - TEST PASSED'
else
   echo 'BAD BOT NOT DETECTED - TEST FAILED'
   exit 1
fi
}

# *******************************************************
# Function Curl Test 8 - Check for Bad Bot "Discoverybot"
# *******************************************************

run_curltest8 () {
truncate -s 0 $_curltest8
printf '%s%s\n\n' "Last Tested: " "$_now" >> "$_curltest8"
curl -A "Discoverybot" http://local.dev:80/index.html 2>&1 >> $_curltest8
if grep -i 'Forbidden' $_curltest8; then
   echo 'BAD BOT DETECTED - TEST PASSED'
else
   echo 'BAD BOT NOT DETECTED - TEST FAILED'
   exit 1
fi
}

# ****************************************************
# Function Curl Test 9 - Check for Bad Bot "Disco Bot"
# ****************************************************

run_curltest9 () {
truncate -s 0 $_curltest9
printf '%s%s\n\n' "Last Tested: " "$_now" >> "$_curltest9"
curl -A "Disco Bot" http://local.dev:80/index.html 2>&1 >> $_curltest9
if grep -i 'Forbidden' $_curltest9; then
   echo 'BAD BOT DETECTED - TEST PASSED'
else
   echo 'BAD BOT NOT DETECTED - TEST FAILED'
   exit 1
fi
}

# ******************************************************
# Function Curl Test 10 - Check for Bad Bot "Web Bandit"
# ******************************************************

run_curltest10 () {
truncate -s 0 $_curltest10
printf '%s%s\n\n' "Last Tested: " "$_now" >> "$_curltest10"
curl -A "Web Bandit" http://local.dev:80/index.html 2>&1 >> $_curltest10
if grep -i 'Forbidden' $_curltest10; then
   echo 'BAD BOT DETECTED - TEST PASSED'
else
   echo 'BAD BOT NOT DETECTED - TEST FAILED'
   exit 1
fi
}

# *****************************************************
# Function Curl Test 11 - Check for Bad Bot "WebBandit"
# *****************************************************

run_curltest11 () {
truncate -s 0 $_curltest11
printf '%s%s\n\n' "Last Tested: " "$_now" >> "$_curltest11"
curl -A "WebBandit" http://local.dev:80/index.html 2>&1 >> $_curltest11
if grep -i 'Forbidden' $_curltest11; then
   echo 'BAD BOT DETECTED - TEST PASSED'
else
   echo 'BAD BOT NOT DETECTED - TEST FAILED'
   #exit 1
fi
}

# *********************************
# Trigger our curl functions to run
# *********************************

run_curltest1
run_curltest2
run_curltest3
run_curltest4
run_curltest5
run_curltest6
run_curltest7
run_curltest8
run_curltest9
run_curltest10
run_curltest11

# ****************************************
# If everything passed then we exit with 0
# ****************************************

exit 0

