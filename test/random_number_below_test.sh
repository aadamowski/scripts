#!/bin/sh
# Unit tests for random_number_below.sh
# Uses bash because the script relies on $RANDOM (bash builtin).

SCRIPT="/scripts/random_number_below.sh"

test_output_below_limit() {
    out=$(bash "$SCRIPT" 50)
    ok=0
    if [ -n "$out" ] && [ "$out" -ge 0 ] && [ "$out" -le 50 ]; then
        ok=1
    fi
    assertTrue "Output should be between 0 and 50 (got: $out)" "[ $ok -eq 1 ]"
}

. /usr/bin/shunit2
