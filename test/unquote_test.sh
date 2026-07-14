#!/bin/sh
# Unit tests for unquote.py (URL decode)
SCRIPT="/scripts/unquote.py"
PY="python2.7"

test_unquote_percent_encoding() {
    out=$(echo "a%20b" | $PY "$SCRIPT" 2>/dev/null)
    assertEquals "a%20b should decode to 'a b'" "a b" "$out"
}

test_unquote_plus() {
    out=$(echo "hello%20world" | $PY "$SCRIPT" 2>/dev/null)
    assertEquals "hello%20world should decode" "hello world" "$out"
}

test_unquote_mixed() {
    out=$(echo "a%20b%20c" | $PY "$SCRIPT" 2>/dev/null)
    assertEquals "a%20b%20c should decode to 'a b c'" "a b c" "$out"
}

. /usr/bin/shunit2
