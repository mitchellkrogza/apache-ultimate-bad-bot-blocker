# ********************************************************
# PRINT VERSION INFORMATION INTO CentOS6 README.md
# ********************************************************

printf '%s\n%s%s\n%s%s\n%s%s\n%s' "${startmarker}" "#### Version: " "${my_git_tag}" "#### Bad Referrer Count: " "${bad_referrers}" "#### Bad Bot Count: " "${bad_bots}" "${endmarker}" >> "${tmpapacheA}"
mv ${tmpapacheA} ${inputdbA}
ed -s ${inputdbA}<<\IN
1,/_______________/d
/____________________/,$d
,d
.r /home/travis/build/mitchellkrogza/apache-ultimate-bad-bot-blocker/_other_distros/CentOS6/README.md
/_______________/x
.t.
.,/____________________/-d
w /home/travis/build/mitchellkrogza/apache-ultimate-bad-bot-blocker/_other_distros/CentOS6/README.md
q
IN
rm ${inputdbA}

# ********************************************************
# PRINT VERSION INFORMATION INTO CentOS6 CONFIGURATION.md
# ********************************************************

printf '%s\n%s%s\n%s%s\n%s%s\n%s' "${startmarker}" "#### Version: " "${my_git_tag}" "#### Bad Referrer Count: " "${bad_referrers}" "#### Bad Bot Count: " "${bad_bots}" "${endmarker}" >> "${tmpapacheA}"
mv ${tmpapacheA} ${inputdbA}
ed -s ${inputdbA}<<\IN
1,/_______________/d
/____________________/,$d
,d
.r /home/travis/build/mitchellkrogza/apache-ultimate-bad-bot-blocker/_other_distros/CentOS6/CONFIGURATION.md
/_______________/x
.t.
.,/____________________/-d
w /home/travis/build/mitchellkrogza/apache-ultimate-bad-bot-blocker/_other_distros/CentOS6/CONFIGURATION.md
q
IN
rm ${inputdbA}

# ********************************************************
# PRINT VERSION INFORMATION INTO CentOS7 README.md
# ********************************************************

printf '%s\n%s%s\n%s%s\n%s%s\n%s' "${startmarker}" "#### Version: " "${my_git_tag}" "#### Bad Referrer Count: " "${bad_referrers}" "#### Bad Bot Count: " "${bad_bots}" "${endmarker}" >> "${tmpapacheA}"
mv ${tmpapacheA} ${inputdbA}
ed -s ${inputdbA}<<\IN
1,/_______________/d
/____________________/,$d
,d
.r /home/travis/build/mitchellkrogza/apache-ultimate-bad-bot-blocker/_other_distros/CentOS7/README.md
/_______________/x
.t.
.,/____________________/-d
w /home/travis/build/mitchellkrogza/apache-ultimate-bad-bot-blocker/_other_distros/CentOS7/README.md
q
IN
rm ${inputdbA}

# ********************************************************
# PRINT VERSION INFORMATION INTO CentOS7 CONFIGURATION.md
# ********************************************************

printf '%s\n%s%s\n%s%s\n%s%s\n%s' "${startmarker}" "#### Version: " "${my_git_tag}" "#### Bad Referrer Count: " "${bad_referrers}" "#### Bad Bot Count: " "${bad_bots}" "${endmarker}" >> "${tmpapacheA}"
mv ${tmpapacheA} ${inputdbA}
ed -s ${inputdbA}<<\IN
1,/_______________/d
/____________________/,$d
,d
.r /home/travis/build/mitchellkrogza/apache-ultimate-bad-bot-blocker/_other_distros/CentOS7/CONFIGURATION.md
/_______________/x
.t.
.,/____________________/-d
w /home/travis/build/mitchellkrogza/apache-ultimate-bad-bot-blocker/_other_distros/CentOS7/CONFIGURATION.md
q
IN
rm ${inputdbA}