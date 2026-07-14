#!/bin/sh
# Unit tests for proc_fdinfo_seek_pos_pct.sh

SCRIPT="/scripts/proc_fdinfo_seek_pos_pct.sh"

test_usage_without_args() {
    out=$("$SCRIPT" 2>&1)
    ok=0
    case "$out" in
        *Usage:*) ok=1 ;;
    esac
    assertTrue "Should show usage when no args" "[ $ok -eq 1 ]"
}

test_usage_with_one_arg() {
    out=$("$SCRIPT" 1 2>&1)
    ok=0
    case "$out" in
        *Usage:*) ok=1 ;;
    esac
    assertTrue "Should show usage when only one arg" "[ $ok -eq 1 ]"
}

. /usr/bin/shunit2
