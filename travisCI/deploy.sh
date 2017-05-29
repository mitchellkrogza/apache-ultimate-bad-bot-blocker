#!/bin/bash
YEAR=$(date +"%Y")
MONTH=$(date +"%m")
git remote rm origin
git config --global user.email "${GIT_EMAIL}"
git config --global user.name "${GIT_NAME}"
git config --global push.default simple
git remote add origin https://${GH_TOKEN}@github.com/${TRAVIS_REPO_SLUG}.git
export GIT_TAG=V2.$YEAR.$MONTH.$TRAVIS_BUILD_NUMBER
#git fetch --tags
#msg="V3.$YEAR.$MONTH.$TRAVIS_BUILD_NUMBER"
#if git tag $GIT_TAG -a -m "$msg" 2>/dev/null; then
git tag $GIT_TAG -a -m "V2.$YEAR.$MONTH.$TRAVIS_BUILD_NUMBER"
git push origin master && git push origin master --tags
#ls -aR
#else echo Tag already exists!; fi

