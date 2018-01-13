# git-repo-cleaner
This repo is used to test some scripts how to delete a large file from GIT history
- either by using git filter-list
- or, much faster by using the tool (BFG)[https://rtyley.github.io/bfg-repo-cleaner/]

Add and push a large file by:
```bash
bash add-large-file.sh
```

Clean the repo from the largest file found in git history:
```bash
bash delete-largest-file.sh
```

or faster by using the (BFG)[https://rtyley.github.io/bfg-repo-cleaner/]:
```bash
bash delete-largest-file.sh --bfg
```
