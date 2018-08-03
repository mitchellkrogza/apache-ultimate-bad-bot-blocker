# ****************************************************
# PRINT VERSION INFORMATION INTO README.md Apache 2.2
# ****************************************************

printf '%s\n%s%s\n%s%s\n%s%s\n%s' "${startmarker}" "#### Version: " "${my_git_tag}" "#### Bad Referrer Count: " "${bad_referrers}" "#### Bad Bot Count: " "${bad_bots}" "${endmarker}" >> "${tmpapacheA}"
mv ${tmpapacheA} ${inputdbA}
ed -s ${inputdbA}<<\IN
1,/_______________/d
/____________________/,$d
,d
.r /home/travis/build/mitchellkrogza/apache-ultimate-bad-bot-blocker/Apache_2.2/README.md
/_______________/x
.t.
.,/____________________/-d
w /home/travis/build/mitchellkrogza/apache-ultimate-bad-bot-blocker/Apache_2.2/README.md
q
IN
rm ${inputdbA}

# ******************************************************
# PRINT VERSION INFORMATION INTO README.md Apache 2.4
# ******************************************************

printf '%s\n%s%s\n%s%s\n%s%s\n%s' "${startmarker}" "#### Version: " "${my_git_tag}" "#### Bad Referrer Count: " "${bad_referrers}" "#### Bad Bot Count: " "${bad_bots}" "${endmarker}" >> "${tmpapacheA}"
mv ${tmpapacheA} ${inputdbA}
ed -s ${inputdbA}<<\IN
1,/_______________/d
/____________________/,$d
,d
.r /home/travis/build/mitchellkrogza/apache-ultimate-bad-bot-blocker/Apache_2.4/README.md
/_______________/x
.t.
.,/____________________/-d
w /home/travis/build/mitchellkrogza/apache-ultimate-bad-bot-blocker/Apache_2.4/README.md
q
IN
rm ${inputdbA}

