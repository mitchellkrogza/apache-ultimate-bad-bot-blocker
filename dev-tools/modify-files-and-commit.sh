#!/bin/bash
# Travis CI Generating and Building for the Apache Ultimate Bad Bot Blocker
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

#set -e
#set -o pipefail
export TERM=xterm

# ******************
# Set Some Variables
# ******************

yeartag=$(date +"%Y")
monthtag=$(date +"%m")

# ***************************************************************
# Gzip Our Latest Release So We can Include it the Travis Release
# ***************************************************************

#cd ./.latest_release/
#tar -czf Apache_2.2.tar.gz -C ./Apache_2.2/ .
#tar -czf Apache_2.4.tar.gz -C ./Apache_2.4/ .

# *************************************
# Add all the modified files and commit
# *************************************

# ---------
# FUNCTIONS
# ---------

touch ./dev-tools/buildnumber
lastbuild=$(cat ./dev-tools/buildnumber)
thisbuild=$((lastbuild + 1))

releaseNewVersion () {
latestbuild=V3.${YEAR}.${MONTH}.${thisbuild}
echo ${latestbuild}
echo "${bold}${magenta}Releasing ${latestbuild}"
}

updatebuildnumber () {
echo ${thisbuild} > ./dev-tools/buildnumber
}

commitBuildChanges () {
          updatebuildnumber
          git config --global user.name "mitchellkrogza"
          git config --global user.email "mitchellkrog@gmail.com"
          git add -A
          git commit -m "${latestbuild} [ci skip]"
          git push
}

deployPackage () {
printf "\n"
echo "${bold}${green}DEPLOYING ${latestbuild}"
printf "\n"
          git config --global user.name "mitchellkrogza"
          git config --global user.email "mitchellkrog@gmail.com"
          export GIT_TAG=${latestbuild}
          git tag ${GIT_TAG} -a -m "${latestbuild}"
          sudo git push origin master && git push origin master --tags
echo "${bold}${green}-------------------------------"
echo "${bold}${green}Deploying ${latestbuild}"
echo "${bold}${green}-------------------------------"
printf "\n\n"
}

# -------------
# Run Functions
# -------------

releaseNewVersion
commitBuildChanges
deployPackage

# **********************
# Exit With Error Number
# **********************

exit ${?}


