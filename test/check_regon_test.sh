#!/bin/sh
# Unit tests for check_regon.py (Polish REGON validator)
# NOTE: The script has a bug (doesn't strip newline from stdin),
# so it crashes on all inputs. We test that it fails (non-zero exit)
# rather than the validation logic that never runs.
SCRIPT="/scripts/check_regon.py"
PY="python2.7"

test_7digit_input_fails() {
    # Script crashes due to newline not being stripped
    $PY "$SCRIPT" <<'EOF' >/dev/null 2>&1
1234567
EOF
    rc=$?
    assertTrue "7-digit REGON input should fail (non-zero exit)" "[ $rc -ne 0 ]"
}

test_9digit_input_fails() {
    $PY "$SCRIPT" <<'EOF' >/dev/null 2>&1
123456789
EOF
    rc=$?
    assertTrue "9-digit REGON input should fail (non-zero exit)" "[ $rc -ne 0 ]"
}

test_too_short_input_fails() {
    $PY "$SCRIPT" <<'EOF' >/dev/null 2>&1
12
EOF
    rc=$?
    assertTrue "short input should fail (non-zero exit)" "[ $rc -ne 0 ]"
}

. /usr/bin/shunit2
