#!/bin/sh
# Unit tests for move_files_to_date_subdirs.sh

SCRIPT="/scripts/move_files_to_date_subdirs.sh"

setUp() {
    T=$(mktemp -d)
    cd "$T"
    touch -t 202001011200.00 file1
    touch -t 202105151200.00 file2
}

tearDown() {
    cd /
    rm -rf "$T"
}

test_moves_files_into_date_dirs() {
    "$SCRIPT"
    assertTrue "Should create 2020-01-01 dir" "[ -d \"2020-01-01\" ]"
    assertTrue "file1 moved into 2020-01-01" "[ -f \"2020-01-01/file1\" ]"
    assertTrue "Should create 2021-05-15 dir" "[ -d \"2021-05-15\" ]"
    assertTrue "file2 moved into 2021-05-15" "[ -f \"2021-05-15/file2\" ]"
}

test_no_files_left_in_root() {
    "$SCRIPT"
    # After move, root should have no loose files
    count=$(ls -1A | grep -v -E '^(2020-01-01|2021-05-15)$' | wc -l)
    assertTrue "No loose files should remain in root" "[ \"$count\" -eq 0 ]"
}

. /usr/bin/shunit2
