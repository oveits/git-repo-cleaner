#!/bin/sh

curl https://www.kernel.org/pub/software/scm/git/git-2.1.0.tar.gz > git.tgz
git add git.tgz
git commit -m 'add git tarball'
git rm git.tgz
git commit -m 'oops - removed large tarball'

while true; do
    read -p "Do you wish to push the large local repo to the remote repo? [y|n] > " yn
    case $yn in
        [Yy]* ) git push; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
