#!/bin/sh
# Unit tests for git_list_branches_and_remote_upstreams_tracked.sh

SCRIPT="/scripts/git_list_branches_and_remote_upstreams_tracked.sh"

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

test_lists_branches() {
    out=$("$SCRIPT" 2>/dev/null)
    case "$out" in *main*|*feature*) b=1 ;; *) b=0 ;; esac
    assertTrue "Should list at least one branch" "[ $b -eq 1 ]"
}

test_output_non_empty() {
    out=$("$SCRIPT" 2>/dev/null)
    assertTrue "Output should not be empty" "[ -n \"$out\" ]"
}

. /usr/bin/shunit2
