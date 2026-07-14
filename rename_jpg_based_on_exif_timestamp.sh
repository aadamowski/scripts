#!/usr/bin/env bash
set -euo pipefail
# Author: Aleksander Adamowski

for jpg in *.jpg; do
	tag="$(exif -m -t 0x9003 "$jpg" | perl -pe 'tr/: /-_/;')"
	printf "Renaming [%s] to [%s.jpg]\n" "$jpg" "$tag"
	mv -i "$jpg" "$tag.jpg"
done
