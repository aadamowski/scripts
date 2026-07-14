#!/bin/sh
# Unit tests for check_nrb.py (Polish IBAN validator)
SCRIPT="/scripts/check_nrb.py"
PY="python2.7"

test_valid_iban() {
    out=$(echo "PL61109010140000071219812874" | $PY "$SCRIPT" 2>/dev/null)
    case "$out" in *ok*) v=1 ;; *) v=0 ;; esac
    assertTrue "Valid IBAN should print ok" "[ $v -eq 1 ]"
}

test_invalid_iban_checksum() {
    out=$(echo "PL00000000000000000000000000" | $PY "$SCRIPT" 2>/dev/null)
    case "$out" in *"zla suma kontrolna"*) v=1 ;; *) v=0 ;; esac
    assertTrue "Bad checksum IBAN" "[ $v -eq 1 ]"
}

test_wrong_length() {
    out=$(echo "123" | $PY "$SCRIPT" 2>/dev/null)
    case "$out" in *"Nieprawidlowa dlugosc"*) v=1 ;; *) v=0 ;; esac
    assertTrue "Wrong-length input" "[ $v -eq 1 ]"
}

. /usr/bin/shunit2
