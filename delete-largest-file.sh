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
if [ "$BFG" == "" ]; then
    updateReferences || exit 1
fi

echo
echo "Reflog and perform Garbage Collection:"
expireAndPrune

echo
echo "Now the repo is small:"
printSizeOfRepo || exit 1

while true; do
    read -p "Do you wish to force push the cleaned repo to the remote repo? [y|n]" yn
    case $yn in
        [Yy]* ) git push --force && RESULT=$?; break;;
        [Nn]* ) RESULT=0; exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

exit $RESULT

