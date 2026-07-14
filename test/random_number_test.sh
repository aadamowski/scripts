#!/bin/sh
# Unit tests for random_number.sh

SCRIPT="/scripts/random_number.sh"

test_output_is_single_digit() {
    out=$("$SCRIPT")
    ok=0
    if echo "$out" | grep -qE '^[0-9]+$'; then
        len=${#out}
        if [ "$len" -ge 1 ] && [ "$len" -le 3 ]; then
            ok=1
        fi
    fi
    assertTrue "Output should be 1-3 digits" "[ $ok -eq 1 ]"
}

. /usr/bin/shunit2
