# cicd-pipelines
Repository with GitHub actions to be reused and Terraform modules

## Pre-Commit hook
This repository contains a git hook that formats the files before any commit.
For the pre-commit to occur, change the git hook folder with:
```
git config --local core.hooksPath .githooks/
```