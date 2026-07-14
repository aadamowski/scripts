#!/bin/sh
# Unit tests for rename_to_random.sh

SCRIPT="/scripts/rename_to_random.sh"

setUp() {
    T=$(mktemp -d)
    cd "$T"
    echo "x" > file1
    echo "y" > file2
}

tearDown() {
    cd /
    rm -rf "$T"
}

test_usage_no_args() {
    out=$("$SCRIPT" 2>&1)
    case "$out" in *Uzycie*) u=1 ;; *) u=0 ;; esac
    assertTrue "Should show usage when no args" "[ $u -eq 1 ]"
}

test_renames_existing_file() {
    "$SCRIPT" file1 >/dev/null
    assertFalse "Original name should be gone" "[ -e file1 ]"
    # file2 also exists, so total should still be 2
    count=$(ls -1 | wc -l)
    assertTrue "Two files should exist after rename" "[ \"$count\" -eq 2 ]"
}

test_missing_file_message() {
    out=$("$SCRIPT" nofile 2>&1)
    case "$out" in *nie*) m=1 ;; *) m=0 ;; esac
    assertTrue "Should report missing file" "[ $m -eq 1 ]"
}

test_rename_nonexistent_path() {
    out=$("$SCRIPT" "/nonexistent/path/file.txt" 2>&1)
    case "$out" in *nie*) m=1 ;; *) m=0 ;; esac
    assertTrue "Should report missing file for nonexistent path" "[ $m -eq 1 ]"
}

. /usr/bin/shunit2
