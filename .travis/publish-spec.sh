#!/bin/bash

set | grep TRAVIS

if [ "$TRAVIS_REPO_SLUG" == "ndw/specification" ] && [ "$TRAVIS_PULL_REQUEST" == "false" ] && [ "$TRAVIS_BRANCH" == "xproc20" ]; then

  echo -e "Publishing specification...\n"

  cp -R build/langspec $HOME/langspec
  mv $HOME/langspec/Overview.html $HOME/langspec/index.html

  cd $HOME
  git config --global user.email "ndw@nwalsh.com"
  git config --global user.name "ndw"
  git clone --quiet --branch=gh-pages https://${GH_TOKEN}@github.com/ndw/specification gh-pages > /dev/null

  cd gh-pages
  git rm -rf ./langspec
  cp -Rf $HOME/langspec ./langspec
  git add -f .
  git commit -m "Lastest specification on successful travis build $TRAVIS_BUILD_NUMBER auto-pushed to gh-pages"
  git push -fq origin gh-pages > /dev/null

  echo -e "Published specification to gh-pages.\n"

fi
