#!/usr/bin/env bash
set -euo pipefail
#
# Description: Moves a file to a timestamped backup name (in-place) and compresses it.
# The backup is timestamped (YYYY_MM_DD_HH=MM=SS) and compressed with bzip2.
# Dependencies: bash, date, mv, bzip2, basename
# Usage: ./bekap_in_place_unlink.sh <file1> [file2 ...]
# Author: Aleksander Adamowski
#
# Note: The backup is compressed using bzip2.


if [[ $# -ge 1 ]]; then
    while [[ $# -gt 0 ]]; do
        FILE="$1"
        if [[ -e "$FILE" ]]; then
            CURDATE=$(date +%Y_%m_%d_%H=%M=%S)
            BASENAME=$(basename "$FILE")
            DEST="${FILE}.${CURDATE}"
            
            if mv "$FILE" "$DEST"; then
                if bzip2 "$DEST"; then
                    printf "Plik %s został przeniesiony do kopii: %s.bz2\n" "$BASENAME" "$BASENAME"
                else
                    printf "Blad podczas kompresji pliku %s\n" "$DEST" >&2
                    exit 1
                fi
            else
                printf "Blad podczas przenoszenia pliku %s\n" "$FILE" >&2
                exit 1
            fi
        else
            printf "Plik %s nie istnieje\n" "$FILE" >&2
        fi
        shift
    done
else
    printf "Uzycie: %s plik_do_zachowania [plik2 ...]\n" "$0" >&2
    exit 1
fi
