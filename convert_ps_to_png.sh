#!/usr/bin/env bash
set -euo pipefail
#
# Description: Converts PostScript files to PNG using ImageMagick.
# Dependencies: bash, ImageMagick (convert)
# Usage: ./convert_ps_to_png.sh <file.ps>
# Author: Aleksander Adamowski
#
# Note: Uses ImageMagick's convert tool.


FILE="$1"

if [[ -f "$FILE" ]]; then
    convert -geometry 25% -density 288 +dither "$FILE" "png:${FILE}%02d.png"
else
    printf "Plik %s nie istnieje lub nie jest plikiem zwyklym\n" "$FILE" >&2
    exit 1
fi

