# git-repo-cleaner
This repo is used to test some scripts how to delete a large file from GIT history
- either by using git filter-list
- or, much faster by using the tool [BFG](https://rtyley.github.io/bfg-repo-cleaner/)

## How to apply to your repo

- download delete-largest-file.sh

  e.g. curl https://raw.githubusercontent.com/oveits/git-repo-cleaner/master/delete-largest-file.sh
- goto local repo

  e.g. clone to local:
  ```bash
  git clone <your-repo>
  cd <your-repo>
  ```
- apply to your repo: run delete-largest-file.sh --bfd and follow the instructions
  ```bash
  ../delete-largest-file.sh --bfd
  ```
  The option --bfd will speed up the process of filtering; especially, if you have many commits in the repo

## How to test git-repo-cleaner repo

Before you apply the scripts to you repo, you might want to test the scripts on a copy of the current repo.

Fork this repo https://github.com/oveits/git-repo-cleaner into your own account.

Clone your copy of the repo (replace yourgitaccount below by your git account name)
```bash
git clone https://github.com/<yourgitaccount>/git-repo-cleaner
```

Add and push a large file by:
```bash
bash add-large-file.sh
```

Clean the repo from the largest file found in git history:
```bash
bash delete-largest-file.sh --bfd
```
The `-bfg` option will cause the [BFG tool](https://rtyley.github.io/bfg-repo-cleaner/) to be downloaded for faster processing.

If you wish, you can also test the filter that comes with GIT (will take longer):
```bash
bash delete-largest-file.sh
```
