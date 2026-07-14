#!/bin/sh
# Unit tests for git_sum_blob_sizes_introduced_by_commit.sh

SCRIPT="/scripts/git_sum_blob_sizes_introduced_by_commit.sh"

setUp() {
    T=$(mktemp -d)
    cd "$T"
    git init -q
    git config user.email "test@test.com"
    git config user.name "Test"
    echo "hello" > file
    git add file
    git commit -q -m "add file"
    COMMIT=$(git rev-parse HEAD)
    export TEST_COMMIT="$COMMIT"
}

tearDown() {
    cd /
    rm -rf "$T"
}

test_sum_output_format() {
    out=$("$SCRIPT" "$TEST_COMMIT" 2>/dev/null)
    # Script outputs "Summary size of blobs introduced by commit"
    case "$out" in *"Summary size of blobs introduced by commit"*) s=1 ;; *) s=0 ;; esac
    assertTrue "Should output summary line" "[ $s -eq 1 ]"
}

test_invalid_commit_still_runs() {
    # Script still outputs summary line even for invalid commits (with 0 bytes)
    out=$("$SCRIPT" "0000000000000000000000000000000000000000" 2>&1)
    case "$out" in *"Summary size of blobs introduced by commit"*) s=1 ;; *) s=0 ;; esac
    assertTrue "Should output summary line even for invalid commit" "[ $s -eq 1 ]"
}

. /usr/bin/shunit2
