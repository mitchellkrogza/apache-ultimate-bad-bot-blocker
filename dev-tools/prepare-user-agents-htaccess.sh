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

input=./_generator_lists/bad-user-agents.list
inputtmp=./dev-tools/_htaccess_generator_files/bad-user-agents.tmp
output=./dev-tools/_htaccess_generator_files/bad-user-agents.list

# ***********************
# Truncate our input file
# ***********************

sudo truncate -s 0 ${output}

# *************************************
# Use sed to prepare our new input file
# *************************************

cat ${input} | sed 's/\\ / /g' | sed 's/[^[:alnum:]]/\\&/g' > ${inputtmp} && mv ${inputtmp} ${output}


# *************************************
# Sort our output file and remove dupes
# *************************************

sort -u ${output} -o ${output}

# **********************
# Exit With Error Number
# **********************

exit ${?}
