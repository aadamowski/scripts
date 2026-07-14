#!/usr/bin/env bash
set -euo pipefail
# Author: Aleksander Adamowski
# Zmienia dane orientacji EXIF, zachowuje czas modyfikacji pliku

orient="$1"
plik="$2"

randname="$(dd if=/dev/urandom bs=256 count=1 2>/dev/null | md5sum -b | cut -b 1-32).tmp"

touch -r "$plik" "$randname"
jpegexiforient "$orient" "$plik"
touch -r "$randname" "$plik"
rm "$randname"

