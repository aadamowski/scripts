#!/bin/sh

for rawfile in "$@"; do
	outfile="$rawfile.jpg"
	if [ -e "$oufile" ]; then
		echo "ERROR: $outfile already exists!" > /dev/stderr
	else
		echo "Converting $rawfile to $outfile..."
		ufraw-batch  --out-type=jpeg "--output=$outfile" "$rawfile"
	fi
	
done
