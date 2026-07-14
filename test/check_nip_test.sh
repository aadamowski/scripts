#!/bin/sh
# Unit tests for check_nip.py (Polish NIP validator)
SCRIPT="/scripts/check_nip.py"
PY="python2.7"

test_valid_nip() {
    out=$(echo "0000000000" | $PY "$SCRIPT" 2>/dev/null)
    # 0000000000 is "poprawny" per NIP checksum
    case "$out" in *poprawny*)
        case "$out" in *NIEPOPRAWNY*) v=0 ;; *) v=1 ;; esac ;;
        *) v=0 ;;
    esac
    assertTrue "0000000000 should be NIP poprawny" "[ $v -eq 1 ]"
}

test_invalid_nip() {
    out=$(echo "1234567890" | $PY "$SCRIPT" 2>/dev/null)
    case "$out" in *NIEPOPRAWNY*) v=1 ;; *) v=0 ;; esac
    assertTrue "1234567890 should be NIP NIEPOPRAWNY" "[ $v -eq 1 ]"
}

test_too_short_input_fails() {
    $PY "$SCRIPT" <<'EOF' >/dev/null 2>&1
123
EOF
    rc=$?
    assertTrue "short input should fail (non-zero exit)" "[ $rc -ne 0 ]"
}

. /usr/bin/shunit2
