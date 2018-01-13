#!/bin/sh

# git garbage collection (git gc) is also pack the files and is needed for the git verify-pack command to work fine: 
echo "Perform git garbage collection, which also will pack all objects (needed for the next command):"
echo "git gc"
git gc

echo "Now we look for the largest file object:"
echo "git verify-pack -v .git/objects/pack/pack-*.idx | sort -k 3 -n | tail -1 | tee largest_file"
git verify-pack -v .git/objects/pack/pack-*.idx | sort -k 3 -n | tail -1 | tee largest_file
OBJECT=$(cat largest_file | awk '{print $1}')
	echo OBJECT=$OBJECT

LARGEFILE=$(git rev-list --objects --all | grep $OBJECT | awk '{print $2}')
	echo LARGEFILE=$LARGEFILE

# cleaning of unnecessary files:
rm largest_file*

# to be cautious I do not remove a small shell script file instead of the large git.tgz file, I ask, whether I have found the correct file:
[ "${LARGEFILE}" == "git.tgz" ] && \
if [ "$1" == "--bfg" ]; then
   curl http://repo1.maven.org/maven2/com/madgag/bfg/1.12.16/bfg-1.12.16.jar -o bfg.jar
   java -jar bfg.jar --delete-files $LARGEFILE
   rm bfg.jar
else
   git filter-branch --tag-name-filter 'cat' --index-filter "git rm --ignore-unmatch --cached $LARGEFILE" -- --all
fi

echo 
echo "the repo is still large:"
echo "$ du -h -d 1"
du -h -d 1

echo "$ git count-objects -v"
git count-objects -v

# found e.g. on https://itextpdf.com/blog/how-completely-remove-file-git-repository:
echo
echo "Update all references:"
echo '$ git for-each-ref --format="%(refname)" refs/original/ | xargs -n 1 git update-ref -d'
git for-each-ref --format="%(refname)" refs/original/ | xargs -n 1 git update-ref -d

echo 
echo "Reflog and perform Garbage Collection:"
echo "$ git reflog expire --expire=now --all"
git reflog expire --expire=now --all
echo "$ git gc --prune=now"
git gc --prune=now

echo
echo "Now the repo is small:"
echo "$ du -h -d 1"
du -h -d 1
echo "$ git count-objects -v"
git count-objects -v


while true; do
    read -p "Do you wish to force push the cleaned repo to the remote repo? [y|n]" yn
    case $yn in
        [Yy]* ) git push --force; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
