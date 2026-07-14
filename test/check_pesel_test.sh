#!/bin/sh
# Unit tests for check_pesel.py (Polish PESEL validator)
SCRIPT="/scripts/check_pesel.py"
PY="python2.7"

test_valid_pesel() {
    out=$(echo "83081110024" | $PY "$SCRIPT" 2>/dev/null)
    # 83081110024 is "poprawny" per PESEL checksum
    case "$out" in *poprawny*)
        case "$out" in *NIEPOPRAWNY*) v=0 ;; *) v=1 ;; esac ;;
        *) v=0 ;;
    esac
    assertTrue "83081110024 should be PESEL poprawny" "[ $v -eq 1 ]"
}

test_invalid_pesel() {
    out=$(echo "83081110044" | $PY "$SCRIPT" 2>/dev/null)
    case "$out" in *NIEPOPRAWNY*) v=1 ;; *) v=0 ;; esac
    assertTrue "83081110044 should be NIEPOPRAWNY" "[ $v -eq 1 ]"
}

test_too_short_input_fails() {
    $PY "$SCRIPT" <<'EOF' >/dev/null 2>&1
123
EOF
    rc=$?
    assertTrue "short input should fail (non-zero exit)" "[ $rc -ne 0 ]"
}

. /usr/bin/shunit2
