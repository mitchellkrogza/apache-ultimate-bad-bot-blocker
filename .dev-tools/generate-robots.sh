#!/bin/bash
# Generator Script for the Apache Ultimate Bad Bot Blocker
# Created by: Mitchell Krog (mitchellkrog@gmail.com)
# Copyright: Mitchell Krog - https://github.com/mitchellkrogza
# Repo Url: https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker

# Generate a robots.txt file for those unable to use the full Apache Ultimate Bad Bot Blocker

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

# ***************
# Set Input Files
# ***************

input1=${TRAVIS_BUILD_DIR}/_generator_lists/bad-user-agents.list
tmprobots=/tmp/robots.txt
inputtmp=${TRAVIS_BUILD_DIR}/.dev-tools/_robots_generator_files/robots.tmp
output=${TRAVIS_BUILD_DIR}/.dev-tools/_robots_generator_files/robots.list

# ***********************
# Truncate our input file
# ***********************

sudo truncate -s 0 ${output}

# *************************************
# Use sed to prepare our new input file
# *************************************

cat ${input1} | sed 's/\\ / /g' > ${inputtmp} && mv ${inputtmp} ${output}

# ******************
# Set Some Variables
# ******************

yeartag=$(date +"%Y")
monthtag=$(date +"%m")
my_git_tag=V3.${yeartag}.${monthtag}.${TRAVIS_BUILD_NUMBER}
bad_referrers=$(wc -l < ${TRAVIS_BUILD_DIR}/_generator_lists/bad-referrers.list)
bad_bots=$(wc -l < ${TRAVIS_BUILD_DIR}/_generator_lists/bad-user-agents.list)
now="$(date)"

# *************************
# Set Start and End Markers
# *************************

startmarker="### Version Information #"
endmarker="### Version Information ##"


# **************************
# Create the robots.txt file
# **************************

printf '###################################################################\n# The Ultimate robots.txt Bot and User-Agent Blocker\n# Copyright:\n# https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker\n###################################################################\n\n' >> "${tmprobots}"

printf '%s\n%s\n%s%s\n%s%s\n%s%s\n%s\n%s\n\n%s\n%s\n%s\n' "${startmarker}" "###################################################" "### Version: " "${my_git_tag}" "### Updated: " "${now}" "### Bad Bot Count: " "${bad_bots}" "###################################################" "${endmarker}" "User-agent: *" "Disallow: /wp-admin/" "Allow: /wp-admin/admin-ajax.php" >> "${tmprobots}"

while IFS= read -r LINE
do
printf 'User-agent: %s\n%s\n' "${LINE}" "Disallow:/" >> "${tmprobots}"
done < ${output}
printf '\n' >> "${tmprobots}"
sudo cp ${tmprobots} ${TRAVIS_BUILD_DIR}/robots.txt/robots.txt

# **********************
# Exit With Error Number
# **********************

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