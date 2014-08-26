#!/bin/bash

set | grep TRAVIS

if [ "$TRAVIS_REPO_SLUG" == "$GIT_PUB_REPO" ] && [ "$TRAVIS_BRANCH" == "$GIT_PUB_BRANCH" ]; then
    echo -e "Setting up for publication...\n"

    cp -R build/langspec $HOME/langspec
    mv $HOME/langspec/Overview.html $HOME/langspec/index.html

    cd $HOME
    git config --global user.email ${GIT_EMAIL}
    git config --global user.name ${GIT_NAME}
    git clone --quiet --branch=gh-pages https://${GH_TOKEN}@github.com/${GIT_PUB_REPO} gh-pages > /dev/null

    if [ "$TRAVIS_PULL_REQUEST" == "false" ]; then
        echo -e "Publishing specification...\n"

        cd gh-pages
        git rm -rf ./langspec
        cp -Rf $HOME/langspec ./langspec

        git add -f .
        git commit -m "Latest specification on successful travis build $TRAVIS_BUILD_NUMBER auto-pushed to gh-pages"
        git push -fq origin gh-pages > /dev/null

        echo -e "Published specification to gh-pages.\n"
    else
        echo -e "Publication cannot be performed on pull requests.\n"
    fi
fi
