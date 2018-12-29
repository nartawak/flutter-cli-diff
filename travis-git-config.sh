#!/usr/bin/env bash

if [ -z "${GITHUB_TOKEN}" ]; then

    echo 'GITHUB_TOKEN is not defined, you have to set this environment variable'
    exit 1

else
  echo 'Add git configuration remote'

  git config --global user.email "travis@travis-ci.org"
  git config --global user.name "Travis CI"

  git remote set-url origin https://${GITHUB_TOKEN}@github.com/nartawak/flutter-cli-diff.git > /dev/null 2>&1

  echo 'Git remote :'
  git remote -v
fi

