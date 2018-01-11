# with trailing /
#GITPATH="https://github.com/oveits/"
#REPO="git-repo-cleaner-test-bfg"

# without trailing .git:

#git clone ${GITPATH}${REPO} || exit 1
#cd ${REPO}
# git garbage collection (git gc) is also pack the files and is needed for the git verify-pack command to work fine: 
git gc

# now we look for the largest file object:
git verify-pack -v .git/objects/pack/pack-*.idx | sort -k 3 -n | tail -1 | tee largest_file
OBJECT=$(cat largest_file | awk '{print $1}')
	echo OBJECT=$OBJECT

LARGEFILE=$(git rev-list --objects --all | grep $OBJECT | awk '{print $2}')
	echo LARGEFILE=$LARGEFILE

git log --oneline --branches -- ${LARGEFILE} > largest_file_commits
#FIRSTCOMMIT=$(cat largest_file_commits | tail -1 | awk '{print $1}')
#	echo FIRSTCOMMIT=$FIRSTCOMMIT

# to be cautious I do not remove a small shell script file instead of the large git.tgz file, I ask, whether I have found the correct file:
[ "${LARGEFILE}" == "git.tgz" ] && \
git filter-branch --index-filter "git rm --ignore-unmatch --cached $LARGEFILE" -- --all
#java -jar ../bfg.jar --delete-files $LARGEFILE

echo "$ du -h -d 1"
du -h -d 1

echo "$ git count-objects -v"
git count-objects -v

echo '$ git for-each-ref --format="%(refname)" refs/original/ | xargs -n 1 git update-ref -d'
git for-each-ref --format="%(refname)" refs/original/ | xargs -n 1 git update-ref -d

echo "$ git reflog expire --expire=now --all"
git reflog expire --expire=now --all

echo "$ git gc --prune=now"
git gc --prune=now

echo "$ git count-objects -v"
git count-objects -v

echo "$ du -h -d 1"
du -h -d 1

while true; do
    read -p "Do you wish to force push the cleaned repo to the remote repo? [y|n]" yn
    case $yn in
        [Yy]* ) git push --force; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
