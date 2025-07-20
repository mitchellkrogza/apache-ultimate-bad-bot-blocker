#!/bin/bash
# Curl Testing Script for Nginx Ultimate Bad Bot Blocker
# Created by: Mitchell Krog (mitchellkrog@gmail.com)
# Copyright: Mitchell Krog - https://github.com/mitchellkrogza
# Repo Url: https://github.com/mitchellkrogza/nginx-ultimate-bad-bot-blocker

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


run_curltest1 () {
if curl -A "80legs" http://localhost:80/index.html 2>&1 | grep -i 'Forbidden'; then
   echo "${bold}${green}PASSED - ${red}80legs BAD BOT DETECTED"
else
   echo "${bold}${red}FAILED - ${red}80legs BAD BOT NOT DETECTED"
   exit 1
fi
}

run_curltest2 () {
if curl -A "Nutch" http://localhost:80/index.html 2>&1 | grep -i 'Forbidden'; then
   echo "${bold}${green}PASSED - ${red}Nutch BAD BOT DETECTED"
else
   echo "${bold}${red}FAILED - ${red}Nutch BAD BOT NOT DETECTED"
   exit 1
fi
}

run_curltest3 () {
if curl -I http://localhost:80/index.html -e http://100dollars-seo.com 2>&1 | grep -i 'Forbidden'; then
   echo "${bold}${green}PASSED - ${red}100dollars-seo.com BAD REFERRER DETECTED"
else
   echo "${bold}${red}FAILED - ${red}100dollars-seo.com BAD REFERRER NOT DETECTED"
   exit 1
fi
}

run_curltest4 () {
if curl -I http://localhost:80/index.html -e http://zx6.ru 2>&1 | grep -i 'Forbidden'; then
   echo "${bold}${green}PASSED - ${red}zx6.ru BAD REFERRER DETECTED"
else
   echo "${bold}${red}FAILED - ${red}zx6.ru BAD REFERRER NOT DETECTED"
   exit 1
fi
}

run_curltest5 () {
if curl -A "GoogleBot" http://localhost:80/index.html 2>&1 | grep -i 'Welcome'; then
   echo "${bold}${green}PASSED - ${green}GoogleBot GOOD BOT ALLOWED THROUGH"
else
   echo "${bold}${red}FAILED - ${red}GoogleBot GOOD BOT NOT ALLOWED THROUGH"
   exit 1
fi
}

run_curltest6 () {
if curl -A "BingBot" http://localhost:80/index.html 2>&1 | grep -i 'Welcome'; then
   echo "${bold}${green}PASSED - ${green}BingBot GOOD BOT ALLOWED THROUGH"
else
   echo "${bold}${red}FAILED - ${red}BingBot GOOD BOT NOT ALLOWED THROUGH"
   exit 1
fi
}

run_curltest7 () {
if curl http://localhost:80/index.html -e http://google.com 2>&1 | grep -i 'Welcome'; then
   echo "${bold}${green}PASSED - ${green}google.com GOOD REFERRER DETECTED"
else
   echo "${bold}${red}FAILED - ${red}google.com GOOD REFERRER NOT DETECTED"
   exit 1
fi
}

run_curltest8 () {
if curl http://localhost:80/index.html -e http://bing.com 2>&1 | grep -i 'Welcome'; then
   echo "${bold}${green}PASSED - ${red}bing.com GOOD REFERRER DETECTED"
else
   echo "${bold}${red}FAILED - ${red}bing.com GOOD REFERRER NOT DETECTED"
   exit 1
fi
}

run_curltest9 () {
if curl -A "Googlebot/Nutch-1.7" http://localhost:80/index.html 2>&1 | grep -i 'Forbidden'; then
   echo "${bold}${green}PASSED - ${red}Googlebot/Nutch-1.7 BAD BOT DETECTED"
else
   echo "${bold}${red}FAILED - ${red}Googlebot/Nutch-1.7 BAD BOT NOT DETECTED"
   #exit 1
fi
}

run_curltest10 () {
if curl -A "Mozilla/5.0 (X11; Linux x86_64; rv:67.0) Gecko/20100101 Firefox/67.0" http://localhost:80/index.html 2>&1 | grep -i 'Welcome'; then
   echo "${bold}${green}PASSED - NO FALSE POSITIVE on Mozilla/5.0"
else
   echo "${bold}${red}FAILED - FALSE POSITIVE FOUND on Mozilla/5.0"
   exit 1
fi
}

run_curltest11 () {
if curl -A "Mozilla/5.0 (iPhone; CPU iPhone OS 12_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/12.1 Mobile/15E148 Safari/604.1" http://localhost:80/index.html 2>&1 | grep -i 'Welcome'; then
   echo "${bold}${green}PASSED - NO FALSE POSITIVE on Safari"
else
   echo "${bold}${red}FAILED - FALSE POSITIVE FOUND on Safari"
   exit 1
fi
}

run_curltest12 () {
if curl -A "Sogou web spider/4.0" http://localhost:80/index.html 2>&1 | grep -i 'Forbidden'; then
   echo "${bold}${green}PASSED - ${red}Sogou web spider/4.0 BAD BOT DETECTED"
else
   echo "${bold}${red}FAILED - ${red}Sogou web spider/4.0 BAD BOT NOT DETECTED"
   exit 1
fi
}

run_curltest13 () {
if curl -A "oBot" http://localhost:80/index.html 2>&1 | grep -i 'Welcome'; then
   echo "${bold}${green}PASSED - ${green}oBot GOOD BOT ALLOWED THROUGH"
else
   echo "${bold}${red}FAILED - ${red}oBot GOOD BOT NOT ALLOWED THROUGH"
   exit 1
fi
}

run_curltest14 () {
if curl -A "UptimeRobot" http://localhost:80/index.html 2>&1 | grep -i 'Welcome'; then
   echo "${bold}${green}PASSED - ${green}UptimeRobot GOOD BOT ALLOWED THROUGH"
else
   echo "${bold}${red}FAILED - ${red}UptimeRobot GOOD BOT NOT ALLOWED THROUGH"
   exit 1
fi
}

run_curltest15 () {
if curl -A "UptimeRobot/2.0" http://localhost:80/index.html 2>&1 | grep -i 'Welcome'; then
   echo "${bold}${green}PASSED - ${green}UptimeRobot/2.0 GOOD BOT ALLOWED THROUGH"
else
   echo "${bold}${red}FAILED - ${red}UptimeRobot/2.0 GOOD BOT NOT ALLOWED THROUGH"
   exit 1
fi
}

testBadUserAgents () {
shuf -n 10 ./_generator_lists/bad-user-agents.list > ./dev-tools/test_units/random-bots-for-test-quick.tmp
sed 's/\\//g' ./dev-tools/test_units/random-bots-for-test-quick.tmp > ./dev-tools/test_units/random-bots-for-test-quick.list
sudo rm ./dev-tools/test_units/random-bots-for-test-quick.tmp
sort -u ./dev-tools/test_units/random-bots-for-test-quick.list -o ./dev-tools/test_units/random-bots-for-test-quick.list
printf "\n"
echo "${bold}${magenta}---------------------------"
echo "${bold}${magenta}Testing 10 Random Bad Bots"
echo "${bold}${magenta}---------------------------"
IFS=$'\n'
file=./dev-tools/test_units/random-bots-for-test-quick.list
lines=$(cat ${file})
for line in ${lines}; do
   if
   curl -A "${line}" -I http://localhost:80/index.html 2>&1 | grep -i 'Forbidden'; then
   echo "${bold}${green}PASSED - ${red}${line} was ${bold}${red}BLOCKED"
   else
   echo "${bold}${red}FAILED - ${red}${line} was ${bold}${red}NOT BLOCKED"
   exit 1
   fi
done
IFS=""
}

testGoodUserAgents () {
sed 's/\\//g' ./_generator_lists/good-user-agents.list > ./dev-tools/test_units/good-bots-for-test.list
printf "\n"
echo "${bold}${magenta}---------------------"
echo "${bold}${magenta}Testing All Good Bots"
echo "${bold}${magenta}---------------------"
IFS=$'\n'
file=./dev-tools/test_units/good-bots-for-test.list
lines=$(cat ${file})
for line in ${lines}; do
   if
   curl -A "${line}" http://localhost:80/index.html 2>&1 | grep -i 'Welcome'; then
   echo "${bold}${green}PASSED - ${green}${line} was ${bold}${green}ALLOWED"
   else
   echo "${bold}${red}FAILED - ${red}${line} was ${bold}${red}BLOCKED"
   exit 1
   fi
done
IFS=""
}

testAllowedUserAgents () {
sed 's/\\//g' ./_generator_lists/allowed-user-agents.list > ./dev-tools/test_units/allowed-bots-for-test.list
printf "\n"
echo "${bold}${magenta}------------------------"
echo "${bold}${magenta}Testing All Allowed Bots"
echo "${bold}${magenta}------------------------"
IFS=$'\n'
file=./dev-tools/test_units/allowed-bots-for-test.list
lines=$(cat ${file})
for line in ${lines}; do
   if
   curl -A "${line}" http://localhost:80/index.html 2>&1 | grep -i 'Welcome'; then
   echo "${bold}${green}PASSED - ${green}${line} was ${bold}${green}ALLOWED"
   else
   echo "${bold}${red}FAILED - ${red}${line} was ${bold}${red}BLOCKED"
   exit 1
   fi
done
IFS=""
}

testRandomReferrers () {
shuf -n 10 ./_generator_lists/bad-referrers.list > ./dev-tools/test_units/random-referrers-for-test-quick.list
sort -u ./dev-tools/test_units/random-referrers-for-test-quick.list -o ./dev-tools/test_units/random-referrers-for-test-quick.list
printf "\n"
echo "${bold}${magenta}---------------------------------"
echo "${bold}${magenta}Testing 10 Random Bad Referrers"
echo "${bold}${magenta}---------------------------------"
IFS=$'\n'
file=./dev-tools/test_units/random-referrers-for-test-quick.list
lines=$(cat ${file})
for line in ${lines}; do
   if
   curl -I http://localhost:80/index.html -e "http://${line}" 2>&1 | grep -i 'Forbidden'; then
   echo "${bold}${green}PASSED - ${red}${line} was ${bold}${red}BLOCKED"
   else
   echo "${bold}${red}FAILED - ${red}${line} was ${bold}${red}NOT BLOCKED"
   exit 1
   fi
done
IFS=""
}

testGoodReferrers () {
printf "\n"
echo "${bold}${magenta}----------------------"
echo "${bold}${magenta}Testing Good Referrers"
echo "${bold}${magenta}----------------------"
IFS=$'\n'
file=./dev-tools/test_units/good-referrers-for-test.list
lines=$(cat ${file})
for line in ${lines}; do
   if
   curl -v -A "${line}" http://localhost:80/index.html 2>&1 | grep -i 'Welcome'; then
   echo "${bold}${green}PASSED - ${green}${line} was ${bold}${green}ALLOWED"
   else
   echo "${bold}${green}FAILED - ${red}${line} was ${bold}${red}BLOCKED"
   exit 1
   fi
done
IFS=""
}

# -----------------
# Trigger Functions
# -----------------

echo "${bold}${green}--------------"
echo "${bold}${green}Tests Starting"
echo "${bold}${green}--------------"
printf "\n"

run_curltest1
run_curltest2
run_curltest3
run_curltest4
run_curltest5
run_curltest6
run_curltest7
run_curltest8
#run_curltest9
run_curltest10
run_curltest11
run_curltest12
#run_curltest13
run_curltest14
run_curltest15
testBadUserAgents
testGoodUserAgents
testAllowedUserAgents
testRandomReferrers
testGoodReferrers

printf "\n"
echo "${bold}${cyan}Tests Completed"
echo "${bold}${green}All Tests Passed"

# ----------------------
# Exit With Error Number
# ----------------------

exit ${?}

# ------------------------------------------------------------------------------
# MIT License
# ------------------------------------------------------------------------------
# Copyright (c) 2017 Mitchell Krog - mitchellkrog@gmail.com
# https://github.com/mitchellkrogza
# ------------------------------------------------------------------------------
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# ------------------------------------------------------------------------------
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# ------------------------------------------------------------------------------
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
# ------------------------------------------------------------------------------

