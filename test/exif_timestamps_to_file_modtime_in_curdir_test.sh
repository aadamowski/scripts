#!/bin/sh
# Unit tests for exif_timestamps_to_file_modtime_in_curdir.py
SCRIPT="/scripts/exif_timestamps_to_file_modtime_in_curdir.py"
PY="python2.7"

test_missing_dependency_fails_cleanly() {
    T=$(mktemp -d)
    cd /
    out=$($PY "$SCRIPT" 2>&1)
    rc=$?
    cd /
    rm -rf "$T"
    # Expect non-zero exit (due to ImportError) and the word 'ImportError' in output
    case "$out" in *ImportError*) i=1 ;; *) i=0 ;; esac
    assertTrue "Should fail with ImportError" "[ $i -eq 1 ]"
    assertTrue "Should exit non-zero" "[ $rc -ne 0 ]"
}

. /usr/bin/shunit2
