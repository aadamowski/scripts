#!/usr/bin/env bash
set -euo pipefail
#
# Description: Creates an in-place backup of a file by adding a timestamp suffix.
# The backup is timestamped (YYYY_MM_DD_HH=MM=SS) and compressed with bzip2.
# Dependencies: bash, date, cp, bzip2, basename
# Usage: ./bekap_in_place.sh <file1> [file2 ...]
# Author: Aleksander Adamowski
#
# Note: The backup is compressed using bzip2.


if [[ $# -lt 1 ]]; then
    printf "Uzycie: %s <plik1> [plik2 ...]\n" "$0" >&2
    exit 1
fi

while [[ $# -gt 0 ]]; do
    FILE="$1"
    
    if [[ -e "$FILE" ]]; then
        if [[ -f "$FILE" ]]; then
            TIMESTAMP=$(date +%Y_%m_%d_%H=%M=%S)
            BASENAME=$(basename "$FILE")
            DEST="${FILE}.${TIMESTAMP}"
            
            if cp -a "$FILE" "$DEST"; then
                if bzip2 "$DEST"; then
                    printf "Kopia zapasowa (in-place) stworzona: %s.bz2\n" "$BASENAME"
                else
                    printf "Blad podczas kompresji pliku %s\n" "$DEST" >&2
                    exit 1
                fi
            else
                printf "Blad podczas kopiowania pliku %s\n" "$FILE" >&2
                exit 1
            fi
        else
            printf "Plik %s nie istnieje lub nie jest plikiem zwykłym\n" "$FILE" >&2
            exit 1
        fi
    else
        printf "Plik %s nie istnieje\n" "$FILE" >&2
        exit 1
    fi
    shift
done
