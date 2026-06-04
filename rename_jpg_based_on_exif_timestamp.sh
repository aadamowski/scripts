#!/bin/sh

for jpg in *.jpg; do
	tag="$(exif -m -t 0x9003 "$jpg" | perl -pe 'tr/: /-_/;')"
	mv -i "Renaming [$jpg] to [$tag.jpg]"
	mv -i "$jpg" "$tag.jpg"
done
