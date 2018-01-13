#!/bin/sh

getLargestFile() {
    git gc > /dev/null 2>&1 \
    && LARGESTOBJECT=$(git verify-pack -v .git/objects/pack/pack-*.idx | sort -k 3 -n | tail -1 | awk '{print $1}') > /dev/null \
    && LARGESTFILENAME=$(git rev-list --objects --all | grep $LARGESTOBJECT | awk '{print $2}') > /dev/null \
    && echo "$LARGESTFILENAME"
    unset LARGESTOBJECT LARGESTFILENAME
}

filterFile() {
   
    if [ "$1" == "" ]; then
        echo fitlerFile called with no file name
        exit 1
    else
        FILE="$1"
    fi

    if [ "$BFG" == "--bfg" ]; then
        curl http://repo1.maven.org/maven2/com/madgag/bfg/1.12.16/bfg-1.12.16.jar -o bfg.jar
        java -jar bfg.jar --delete-files $FILE
        rm bfg.jar
    else
        git filter-branch --tag-name-filter 'cat' --index-filter "git rm --ignore-unmatch --cached $FILE" -- --all
    fi
}

printSizeOfRepo(){
    [ "$VERBOSE" == "true" ] && echo "git count-objects -v"
    git count-objects -v
    [ "$VERBOSE" == "true" ] && echo "du -h -d 1"
    du -h -d 1
}

updateReferences(){
    [ "$VERBOSE" == "true" ] && echo '$ git for-each-ref --format="%(refname)" refs/original/ | xargs -n 1 git update-ref -d'
    git for-each-ref --format="%(refname)" refs/original/ | xargs -n 1 git update-ref -d
}

expireAndPrune(){
    [ "$VERBOSE" == "true" ] && echo "$ git reflog expire --expire=now --all"
    git reflog expire --expire=now --all
    [ "$VERBOSE" == "true" ] && echo "$ git gc --prune=now"
    git gc --prune=now
}

#
# MAIN
#

BFG=$1
VERBOSE=true

LARGESTFILE=$(getLargestFile)
while true; do
    read -p "The largest File I have found is '$LARGESTFILE'. Do you with to remove this file from GIT History? [y|n] >" yn
    case $yn in
        [Yy]* ) echo "starting..."; break;;
        [Nn]* ) echo "exiting..."; exit 0;;
        * ) echo "Please answer yes or no.";;
    esac
done

echo
echo "filtering $LARGESTFILE ..."
filterFile $LARGESTFILE || exit 1

echo 
echo "the repo is still large:"
printSizeOfRepo || exit 1

echo
echo "Update all references:"
updateReferences || exit 1

echo
echo "Reflog and perform Garbage Collection:"
expireAndPrune

echo
echo "Now the repo is small:"
printSizeOfRepo || exit 1

while true; do
    read -p "Do you wish to force push the cleaned repo to the remote repo? [y|n]" yn
    case $yn in
        [Yy]* ) git push --force || exit 1; break;;
        [Nn]* ) exit 0;;
        * ) echo "Please answer yes or no.";;
    esac
done

echo "Error: You should never reach here"
exit 1

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
