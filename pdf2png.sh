#!/usr/bin/env bash
set -euo pipefail
#
# Description: Converts PDF files to PNG using Ghostscript.
# Dependencies: bash, Ghostscript (gs)
# Usage: ./pdf2png.sh <file.pdf>
# Author: Aleksander Adamowski
#


FILE="$1"

if [[ -f "$FILE" ]]; then
    gs -sDEVICE=png16m -sOutputFile="${FILE}-str%d.png" -r300x300 -q -dBATCH -dNOPAUSE -dTextAlphaBits=4 "$FILE"
else
    printf "Plik %s nie istnieje lub nie jest plikiem zwyklym\n" "$FILE" >&2
    exit 1
fi
