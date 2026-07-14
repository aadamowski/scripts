#!/bin/sh
# Unit tests for rpm_changelog_timestamp.sh

SCRIPT="/scripts/rpm_changelog_timestamp.sh"

test_output_date_format() {
    out=$("$SCRIPT")
    # Should match "Mon MMM DD YYYY"
    echo "$out" | grep -qE '^[A-Z][a-z]{2} [A-Z][a-z]{2} [0-9]{2} [0-9]{4}$'
    assertTrue "Output should match rpm changelog date format" "$?"
}

. /usr/bin/shunit2
