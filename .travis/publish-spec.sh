#!/bin/bash

#set | grep TRAVIS
#set | grep GIT

if [ "$TRAVIS_REPO_SLUG" == "$GIT_PUB_REPO" ] && [ "$TRAVIS_PULL_REQUEST" == "false" ] && [ "$TRAVIS_BRANCH" == "$GIT_PUB_BRANCH" ]; then

  echo -e "Publishing specification...\n"

  cp -R build/langspec $HOME/langspec
  mv $HOME/langspec/Overview.html $HOME/langspec/index.html

  cd $HOME
  git config --global user.email ${GIT_EMAIL}
  git config --global user.name ${GIT_NAME}
  git clone --quiet --branch=gh-pages https://${GH_TOKEN}@github.com/${GIT_PUB_REPO} gh-pages > /dev/null

  cd gh-pages
  git rm -rf ./langspec
  cp -Rf $HOME/langspec ./langspec
  git add -f .
  git commit -m "Lastest specification on successful travis build $TRAVIS_BUILD_NUMBER auto-pushed to gh-pages"
  git push -fq origin gh-pages > /dev/null

  echo -e "Published specification to gh-pages.\n"

fi
