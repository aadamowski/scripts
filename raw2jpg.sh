#!/usr/bin/env bash
set -euo pipefail
#
# Description: Converts RAW images to JPG using ufraw-batch.
# Dependencies: bash, ufraw-batch
# Usage: ./raw2jpg.sh <rawfile1> [rawfile2 ...]
# Author: Aleksander Adamowski

if [[ $# -lt 1 ]]; then
    printf "Uzycie: %s <rawfile1> [rawfile2 ...]\n" "$0" >&2
    exit 1
fi

for RAWFILE in "$@"; do
    if [[ -e "$RAWFILE" ]]; then
        OUTFILE="${RAWFILE}.jpg"
        if [[ -e "$OUTFILE" ]]; then
            printf "ERROR: %s juz istnieje!\n" "$OUTFILE" >&2
        else
            printf "Converting %s to %s...\n" "$RAWFILE" "$OUTFILE"
            ufraw-batch --out-type=jpeg "--output=$OUTFILE" "$RAWFILE"
        fi
    else
        printf "Plik %s nie istnieje\n" "$RAWFILE" >&2
    fi
done
