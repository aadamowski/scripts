#!/usr/bin/env bash
set -euo pipefail
# Author: Aleksander Adamowski
commitid=$1
(
        for blobid in $(
                git diff-tree -r -c -M -C --no-commit-id $commitid | awk '{print $4}'
        ); do
        printf "%s\n" "$blobid" | git cat-file --batch-check;
        done;
) | awk -v commitid=$commitid '
{
        s += $3
}
 END {
        print "Summary size of blobs introduced by commit " commitid ": " s " bytes"
}'

