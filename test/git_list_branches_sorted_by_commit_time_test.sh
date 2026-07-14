#!/bin/sh
# Unit tests for git_list_branches_sorted_by_commit_time.sh

SCRIPT="/scripts/git_list_branches_sorted_by_commit_time.sh"

setUp() {
    T=$(mktemp -d)
    cd "$T"
    git init -q
    git config user.email "test@test.com"
    git config user.name "Test"
    echo "x" > file
    git add file
    git commit -q -m "init"
    git branch feature
}

tearDown() {
    cd /
    rm -rf "$T"
}

test_lists_refs() {
    out=$("$SCRIPT" 2>/dev/null)
    case "$out" in *refs/*) r=1 ;; *) r=0 ;; esac
    assertTrue "Should list refs" "[ $r -eq 1 ]"
}

. /usr/bin/shunit2
