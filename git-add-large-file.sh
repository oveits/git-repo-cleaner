curl https://www.kernel.org/pub/software/scm/git/git-2.1.0.tar.gz > git.tgz
git add git.tgz
git commit -m 'add git tarball'
git rm git.tgz
git commit -m 'oops - removed large tarball'
git push
