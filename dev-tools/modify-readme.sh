#!/bin/bash
# Write Build / Version Number into README.md files
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

# ******************
# Set Some Variables
# ******************

yeartag=$(date +%Y)
monthtag=$(date +%m)
daytag=$(date +%d)
my_git_tag=V3.${yeartag}.${monthtag}.${daytag}
bad_referrers=$(wc -l < ./_generator_lists/bad-referrers.list)
bad_bots=$(wc -l < ./_generator_lists/bad-user-agents.list)
fake_google_bots=$(wc -l < ./_generator_lists/fake-googlebots.list)

# **********************************
# Temporary database files we create
# **********************************

inputdbA=/tmp/lastupdated.db
tmpapacheA=tmpapacheA

# ***************************************************************
# Start and End Strings to Search for to do inserts into template
# ***************************************************************

startmarker="_______________"
endmarker="____________________"
startmarker2="### Version Information #"
endmarker2="### Version Information ##"

# ****************************************
# PRINT VERSION INFORMATION INTO README.md
# ****************************************

printf '%s\n%s%s\n%s%s\n%s%s\n%s%s\n%s' "${startmarker}" "#### Version: " "${my_git_tag}" "#### Bad Referrer Count: " "[${bad_referrers}](https://raw.githubusercontent.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/master/_generator_lists/bad-referrers.list)" "#### Bad Bot Count: " "[${bad_bots}](https://raw.githubusercontent.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/master/_generator_lists/bad-user-agents.list)" "#### Fake Googlebots: " "[${fake_google_bots}](https://raw.githubusercontent.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/master/_generator_lists/fake-googlebots.list)" "${endmarker}" >> "${tmpapacheA}"
mv ${tmpapacheA} ${inputdbA}
ed -s ${inputdbA}<<\IN
1,/_______________/d
/____________________/,$d
,d
.r ./README.md
/_______________/x
.t.
.,/____________________/-d
w ./README.md
q
IN
rm ${inputdbA}

# ******************************************************
# PRINT VERSION INFORMATION INTO CONFIGURATION.md
# ******************************************************

printf '%s\n%s%s\n%s%s\n%s%s\n%s%s\n%s' "${startmarker}" "#### Version: " "${my_git_tag}" "#### Bad Referrer Count: " "[${bad_referrers}](https://raw.githubusercontent.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/master/_generator_lists/bad-referrers.list)" "#### Bad Bot Count: " "[${bad_bots}](https://raw.githubusercontent.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/master/_generator_lists/bad-user-agents.list)" "#### Fake Googlebots: " "[${fake_google_bots}](https://raw.githubusercontent.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/master/_generator_lists/fake-googlebots.list)" "${endmarker}" >> "${tmpapacheA}"

mv ${tmpapacheA} ${inputdbA}
ed -s ${inputdbA}<<\IN
1,/_______________/d
/____________________/,$d
,d
.r ./CONFIGURATION.md
/_______________/x
.t.
.,/____________________/-d
w ./CONFIGURATION.md
q
IN
rm ${inputdbA}

# *******************************************************
# PRINT VERSION INFORMATION INTO htaccess-mod_rewrite.txt
# *******************************************************

printf '%s\n%s%s\n%s%s\n%s%s\n%s' "${startmarker2}" "### Version: " "${my_git_tag}" "### Bad Referrer Count: " "${bad_referrers}" "### Bad Bot Count: " "${bad_bots}" "${endmarker2}" >> "${tmpapacheA}"
mv ${tmpapacheA} ${inputdbA}
ed -s ${inputdbA}<<\IN
1,/### Version Information #/d
/### Version Information ##/,$d
,d
.r ./_htaccess_versions/htaccess-mod_rewrite.txt
/### Version Information #/x
.t.
.,/### Version Information ##/-d
w ./_htaccess_versions/htaccess-mod_rewrite.txt
q
IN
rm ${inputdbA}

# ********************************************************
# PRINT VERSION INFORMATION INTO htaccess-mod_setenvif.txt
# ********************************************************

printf '%s\n%s%s\n%s%s\n%s%s\n%s' "${startmarker2}" "### Version: " "${my_git_tag}" "### Bad Referrer Count: " "${bad_referrers}" "### Bad Bot Count: " "${bad_bots}" "${endmarker2}" >> "${tmpapacheA}"
mv ${tmpapacheA} ${inputdbA}
ed -s ${inputdbA}<<\IN
1,/### Version Information #/d
/### Version Information ##/,$d
,d
.r ./_htaccess_versions/htaccess-mod_setenvif.txt
/### Version Information #/x
.t.
.,/### Version Information ##/-d
w ./_htaccess_versions/htaccess-mod_setenvif.txt
q
IN
rm ${inputdbA}

# ********************************************************
# PRINT VERSION INFORMATION INTO htaccess README.md
# ********************************************************

printf '%s\n%s%s\n%s%s\n%s%s\n%s' "${startmarker}" "#### Version: " "${my_git_tag}" "#### Bad Referrer Count: " "${bad_referrers}" "#### Bad Bot Count: " "${bad_bots}" "${endmarker}" >> "${tmpapacheA}"
mv ${tmpapacheA} ${inputdbA}
ed -s ${inputdbA}<<\IN
1,/_______________/d
/____________________/,$d
,d
.r ./_htaccess_versions/README.md
/_______________/x
.t.
.,/____________________/-d
w ./_htaccess_versions/README.md
q
IN
rm ${inputdbA}


# ********************************************************
# PRINT VERSION INFORMATION INTO CPanel Instructions
# ********************************************************

printf '%s\n%s%s\n%s%s\n%s%s\n%s%s\n%s' "${startmarker}" "#### Version: " "${my_git_tag}" "#### Bad Referrer Count: " "[${bad_referrers}](https://raw.githubusercontent.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/master/_generator_lists/bad-referrers.list)" "#### Bad Bot Count: " "[${bad_bots}](https://raw.githubusercontent.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/master/_generator_lists/bad-user-agents.list)" "#### Fake Googlebots: " "[${fake_google_bots}](https://raw.githubusercontent.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/master/_generator_lists/fake-googlebots.list)" "${endmarker}" >> "${tmpapacheA}"
mv ${tmpapacheA} ${inputdbA}
ed -s ${inputdbA}<<\IN
1,/_______________/d
/____________________/,$d
,d
.r ./_CPanel_Instructions/README.md
/_______________/x
.t.
.,/____________________/-d
w ./_CPanel_Instructions/README.md
q
IN
rm ${inputdbA}

# ********************************************************
# PRINT VERSION INFORMATION Google Ghost Spam README
# ********************************************************

printf '%s\n%s%s\n%s%s\n%s%s\n%s%s\n%s' "${startmarker}" "#### Version: " "${my_git_tag}" "#### Bad Referrer Count: " "[${bad_referrers}](https://raw.githubusercontent.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/master/_generator_lists/bad-referrers.list)" "#### Bad Bot Count: " "[${bad_bots}](https://raw.githubusercontent.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/master/_generator_lists/bad-user-agents.list)" "#### Fake Googlebots: " "[${fake_google_bots}](https://raw.githubusercontent.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/master/_generator_lists/fake-googlebots.list)" "${endmarker}" >> "${tmpapacheA}"
mv ${tmpapacheA} ${inputdbA}
ed -s ${inputdbA}<<\IN
1,/_______________/d
/____________________/,$d
,d
.r ./_google_analytics_ghost_spam/README.md
/_______________/x
.t.
.,/____________________/-d
w ./_google_analytics_ghost_spam/README.md
q
IN
rm ${inputdbA}

# ********************************************************
# PRINT VERSION INFORMATION robots.txt README
# ********************************************************

printf '%s\n%s%s\n%s%s\n%s%s\n%s' "${startmarker}" "#### Version: " "${my_git_tag}" "#### Bad Referrer Count: " "${bad_referrers}" "#### Bad Bot Count: " "${bad_bots}" "${endmarker}" >> "${tmpapacheA}"
mv ${tmpapacheA} ${inputdbA}
ed -s ${inputdbA}<<\IN
1,/_______________/d
/____________________/,$d
,d
.r ./robots.txt/README.md
/_______________/x
.t.
.,/____________________/-d
w ./robots.txt/README.md
q
IN
rm ${inputdbA}

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
