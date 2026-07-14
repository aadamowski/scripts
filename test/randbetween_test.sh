#!/bin/sh
# Unit tests for randbetween.sh

SCRIPT="/scripts/randbetween.sh"

test_output_in_range() {
    out=$("$SCRIPT" 1 10)
    ok=0
    if [ -n "$out" ] && [ "$out" -ge 1 ] && [ "$out" -le 10 ]; then
        ok=1
    fi
    assertTrue "Output should be between 1 and 10" "[ $ok -eq 1 ]"
}

test_output_in_range_100_to_200() {
    out=$("$SCRIPT" 100 200)
    ok=0
    if [ -n "$out" ] && [ "$out" -ge 100 ] && [ "$out" -le 200 ]; then
        ok=1
    fi
    assertTrue "Output should be between 100 and 200" "[ $ok -eq 1 ]"
}

. /usr/bin/shunit2
