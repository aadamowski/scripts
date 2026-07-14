#!/bin/sh
# Unit tests for hexdump2asn1parse.sh

SCRIPT="/scripts/hexdump2asn1parse.sh"

test_parses_valid_der() {
    # Simple ASN.1 DER: INTEGER 42 (0x02 0x01 0x2A)
    out=$(echo "02012a" | "$SCRIPT" 2>/dev/null)
    ok=0
    case "$out" in
        *INTEGER*) ok=1 ;;
    esac
    assertTrue "Should parse ASN.1 INTEGER" "[ $ok -eq 1 ]"
}

. /usr/bin/shunit2
