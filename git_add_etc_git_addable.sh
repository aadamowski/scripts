#!/bin/bash
cd /etc/ && \
/root/bin/find_etc_git_addable.sh | xargs -L 1 git add -A --ignore-errors
