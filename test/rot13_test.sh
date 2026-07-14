#!/bin/sh
# Unit tests for rot13.py
SCRIPT="/scripts/rot13.py"
PY="python2.7"

test_rot13_basic() {
    out=$(echo "abc" | $PY "$SCRIPT" 2>/dev/null)
    case "$out" in *nop*) v=1 ;; *) v=0 ;; esac
    assertTrue "rot13(abc) should be nop" "[ $v -eq 1 ]"
}

test_rot13_roundtrip() {
    out=$(echo "nop" | $PY "$SCRIPT" 2>/dev/null)
    case "$out" in *abc*) v=1 ;; *) v=0 ;; esac
    assertTrue "rot13(nop) should be abc" "[ $v -eq 1 ]"
}

test_rot13_preserves_newlines() {
    out=$(printf "abc\nnop" | $PY "$SCRIPT" 2>/dev/null)
    case "$out" in *nop*) v=1 ;; *) v=0 ;; esac
    assertTrue "rot13 should preserve newlines" "[ $v -eq 1 ]"
}

. /usr/bin/shunit2
