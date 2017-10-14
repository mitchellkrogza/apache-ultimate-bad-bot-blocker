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
#_input=$TRAVIS_BUILD_DIR/_generator_lists/bad-user-agents-htaccess.list
_output=$TRAVIS_BUILD_DIR/.dev-tools/_htaccess_generator_files/bad-user-agents.list

# *****************
# Truncate our file
# *****************

sudo truncate -s 0 $_output

# ********************************************
# Use sed to strip the \ out of the input file
# ********************************************

#sed 's/\\ / /g' $_input > $_output
#sed 's/\\\([^\\]*\)|\([^\\]*\)\\/\1\2/'  $_input > $_output
#sed 's/\\//g' $_input >$_output
#sed 's/\\\//g' $_input >$_output
#sudo cp $_input $_output
sed 's/[\]//g' $_input > $_output

# *************************************
# Sort our output file and remove dupes
# *************************************

sort -u $_output -o $_output
