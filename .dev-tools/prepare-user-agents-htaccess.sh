#!/bin/bash
# Sort Domain into a plain text file with domain names only
# Created by: Mitchell Krog (mitchellkrog@gmail.com)
# Copyright: Mitchell Krog - https://github.com/mitchellkrogza
# Repo Url: https://github.com/mitchellkrogza/The-Big-List-of-Hacked-Malware-Web-Sites

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

# ******************************
# Specify Input and Output Files
# ******************************

_input=$TRAVIS_BUILD_DIR/_generator_lists/bad-user-agents.list
_inputtmp=$TRAVIS_BUILD_DIR/.dev-tools/_htaccess_generator_files/bad-user-agents.tmp
_inputtmp2=$TRAVIS_BUILD_DIR/.dev-tools/_htaccess_generator_files/bad-user-agents2.tmp
_output=$TRAVIS_BUILD_DIR/.dev-tools/_htaccess_generator_files/bad-user-agents.list
_output2=$TRAVIS_BUILD_DIR/.dev-tools/_htaccess_generator_files/bad-user-agents2.list

# ***********************
# Truncate our input file
# ***********************

sudo truncate -s 0 $_output
sudo truncate -s 0 $_output2

# *************************************
# Use sed to prepare our new input file
# *************************************

cat $_input | sed 's/\\ / /g' | sed 's/[^[:alnum:]_]/\\&/g' > $_inputtmp && mv $_inputtmp $_output

# Test above using awk

cat $_input | awk 'gsub(/[^[:alnum:]]/,"\\\\&")+1' > $_inputtmp2 && mv $_inputtmp2 $_output2

# *************************************
# Sort our output file and remove dupes
# *************************************

sort -u $_output -o $_output
sort -u $_output2 -o $_output2
