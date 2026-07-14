#!/bin/sh
# Unit tests for mkdir_curdate.sh

SCRIPT="/scripts/mkdir_curdate.sh"

setUp() {
    T=$(mktemp -d)
    cd "$T"
}

tearDown() {
    cd /
    rm -rf "$T"
}

test_creates_date_directory() {
    "$SCRIPT"
    expected=$(date +%F)
    assertTrue "Should create directory named with today's date" "[ -d \"$expected\" ]"
}

test_no_args_required() {
    "$SCRIPT"
    assertTrue "Should not fail without arguments" "[ -d \"$(date +%F)\" ]"
}

. /usr/bin/shunit2
