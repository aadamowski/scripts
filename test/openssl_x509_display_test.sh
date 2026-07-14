#!/bin/sh
# Unit tests for openssl_x509_display.sh

SCRIPT="/scripts/openssl_x509_display.sh"

setUp() {
    T=$(mktemp -d)
    cd "$T"
    openssl req -x509 -newkey rsa:512 -nodes -keyout key.pem -out cert.pem -days 1 -subj "/CN=test" -batch 2>/dev/null
}

tearDown() {
    cd /
    rm -rf "$T"
}

test_displays_cert_text() {
    out=$("$SCRIPT" cert.pem 2>/dev/null)
    case "$out" in *Subject:*) s=1 ;; *) s=0 ;; esac
    assertTrue "Should display certificate subject" "[ $s -eq 1 ]"
}

test_missing_file_error() {
    out=$("$SCRIPT" nonexistent.pem 2>&1)
    case "$out" in *Subject:*) s=1 ;; *) s=0 ;; esac
    assertFalse "Should not display subject for missing file" "[ $s -eq 1 ]"
}

. /usr/bin/shunit2
