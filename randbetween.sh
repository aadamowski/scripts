#!/usr/bin/env bash
set -euo pipefail
#
# Description: Generates a random number between two given values.
# Dependencies: bash
# Usage: ./randbetween.sh <min> <max>
# Author: Aleksander Adamowski
#


if [[ $# -ne 2 ]]; then
    printf "Usage: %s <min> <max>\n" "$0" >&2
    exit 1
fi

printf '%d\n' $(( ( RANDOM % ($2 - $1 + 1 ) ) + $1 ));
