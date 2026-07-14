#!/bin/sh
# Unit tests for find_etc_git_addable.sh

SCRIPT="/scripts/find_etc_git_addable.sh"

setUp() {
    T=$(mktemp -d)
    cd "$T"
    mkdir -p etc
    cd etc

    echo "x" > file1
    chmod 644 file1

    mkdir -p .git
    echo "x" > .git/HEAD
    chmod 644 .git/HEAD

    mkdir -p opt/Adobe
    echo "x" > opt/Adobe/file
    chmod 644 opt/Adobe/file

    mkdir -p ssl
    echo "x" > ssl/cert.pem
    chmod 644 ssl/cert.pem

    echo "x" > mtab
    chmod 644 mtab
    echo "x" > ld.so.cache
    chmod 644 ld.so.cache

    echo "x" > private
    chmod 600 private
}

tearDown() {
    cd /
    rm -rf "$T"
}

test_finds_public_files() {
    out=$(cd "$T/etc" && "$SCRIPT" -print 2>/dev/null)
    case "$out" in *file1*) f=1 ;; *) f=0 ;; esac
    assertTrue "Should find public file1" "[ $f -eq 1 ]"
}

test_excludes_git() {
    out=$(cd "$T/etc" && "$SCRIPT" -print 2>/dev/null)
    case "$out" in *.git/HEAD*) g=1 ;; *) g=0 ;; esac
    assertFalse "Should exclude .git" "[ $g -eq 1 ]"
}

test_excludes_adobe() {
    out=$(cd "$T/etc" && "$SCRIPT" -print 2>/dev/null)
    case "$out" in *opt/Adobe/file*) a=1 ;; *) a=0 ;; esac
    assertFalse "Should exclude Adobe" "[ $a -eq 1 ]"
}

test_excludes_ssl() {
    out=$(cd "$T/etc" && "$SCRIPT" -print 2>/dev/null)
    case "$out" in *ssl/cert.pem*) s=1 ;; *) s=0 ;; esac
    assertFalse "Should exclude ssl" "[ $s -eq 1 ]"
}

test_excludes_mtab() {
    out=$(cd "$T/etc" && "$SCRIPT" -print 2>/dev/null)
    case "$out" in *mtab*) m=1 ;; *) m=0 ;; esac
    assertFalse "Should exclude mtab" "[ $m -eq 1 ]"
}

test_excludes_ld_so_cache() {
    out=$(cd "$T/etc" && "$SCRIPT" -print 2>/dev/null)
    case "$out" in *ld.so.cache*) l=1 ;; *) l=0 ;; esac
    assertFalse "Should exclude ld.so.cache" "[ $l -eq 1 ]"
}

test_excludes_private() {
    out=$(cd "$T/etc" && "$SCRIPT" -print 2>/dev/null)
    case "$out" in *private*) p=1 ;; *) p=0 ;; esac
    assertFalse "Should exclude non-public file" "[ $p -eq 1 ]"
}

. /usr/bin/shunit2
