#!/bin/sh
# Unit tests for openssl_req_display.sh

SCRIPT="/scripts/openssl_req_display.sh"

setUp() {
    T=$(mktemp -d)
    cd "$T"
    openssl req -new -newkey rsa:512 -nodes -keyout key.pem -out req.pem -subj "/CN=test" -batch 2>/dev/null
}

tearDown() {
    cd /
    rm -rf "$T"
}

test_displays_req_text() {
    out=$("$SCRIPT" req.pem 2>/dev/null)
    case "$out" in *Subject:*) s=1 ;; *) s=0 ;; esac
    assertTrue "Should display CSR subject" "[ $s -eq 1 ]"
}

test_missing_file_error() {
    out=$("$SCRIPT" nonexistent.pem 2>&1)
    case "$out" in *Subject:*) s=1 ;; *) s=0 ;; esac
    assertFalse "Should not display subject for missing file" "[ $s -eq 1 ]"
}

. /usr/bin/shunit2
