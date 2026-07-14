#!/bin/sh
# Unit tests for bekap_in_place_unlink.sh using shunit2.

SCRIPT="/scripts/bekap_in_place_unlink.sh"

setUp() {
    T=$(mktemp -d)
    cd "$T"
    echo "content" > "$T/file1.txt"
    echo "other"   > "$T/file2.txt"
}

tearDown() {
    cd /
    rm -rf "$T"
}

test_usage_no_args() {
    out=$("$SCRIPT" 2>&1)
    case "$out" in *Uzycie*) u=1 ;; *) u=0 ;; esac
    assertTrue "Should print usage when no args" "[ $u -eq 1 ]"
}

test_unlink_existing_file() {
    "$SCRIPT" "$T/file1.txt"
    assertFalse "Original file should no longer exist" "[ -f \"$T/file1.txt\" ]"
    assertTrue "Backup bz2 file should exist" "ls \"$T\"/file1.txt.*.bz2 >/dev/null 2>&1"
}

test_multiple_files_unlinked() {
    "$SCRIPT" "$T/file1.txt" "$T/file2.txt"
    assertFalse "file1 should no longer exist" "[ -f \"$T/file1.txt\" ]"
    assertFalse "file2 should no longer exist" "[ -f \"$T/file2.txt\" ]"
    assertTrue "file1 backup exists" "ls \"$T\"/file1.txt.*.bz2 >/dev/null 2>&1"
    assertTrue "file2 backup exists" "ls \"$T\"/file2.txt.*.bz2 >/dev/null 2>&1"
}

test_missing_file_message() {
    out=$("$SCRIPT" "$T/does_not_exist.txt" 2>&1)
    case "$out" in *plik*nicht*|*plik*nie*) m=1 ;; *) m=0 ;; esac
    assertTrue "Should report missing file" "[ $m -eq 1 ]"
}

test_backup_nonexistent_directory() {
    out=$("$SCRIPT" "/nonexistent/path/file.txt" 2>&1)
    case "$out" in *plik*nicht*|*plik*nie*) m=1 ;; *) m=0 ;; esac
    assertTrue "Should report missing file for nonexistent path" "[ $m -eq 1 ]"
}

. /usr/bin/shunit2
