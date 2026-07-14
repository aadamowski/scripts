#!/bin/sh
# Unit tests for correct_permissions_for_public_access_readonly_noexec.sh

SCRIPT="/scripts/correct_permissions_for_public_access_readonly_noexec.sh"

setUp() {
    T=$(mktemp -d)
    cd "$T"
    mkdir -p sub
    echo "x" > file1
    echo "x" > sub/file2
    chmod 755 file1 sub/file2
}

tearDown() {
    cd /
    rm -rf "$T"
}

test_no_args_sets_permissions() {
    cd "$T" && "$SCRIPT"
    # Regular files should not be executable
    assertFalse "file1 should not be executable" "[ -x file1 ]"
    # Files should be readable
    assertTrue "file1 readable" "[ -r file1 ]"
}

test_subdirectory_files_not_executable() {
    cd "$T" && "$SCRIPT"
    assertFalse "sub/file2 should not be executable" "[ -x sub/file2 ]"
}

. /usr/bin/shunit2
