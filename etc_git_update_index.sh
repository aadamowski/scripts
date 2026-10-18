#!/bin/bash

# Avoid adding non-publicly readable /etc/ files (which can contain sensitive
# secrets):
git add $(/root/bin/find_etc_git_addable.sh )

# But still stage deletions of missing files in the same commit - this way Git
# content management will auto-detect moves and renames:
git ls-files --deleted -z | xargs -0 git rm --cached
