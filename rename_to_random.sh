#!/bin/sh

if [ $# -ge 1 ]; then
	while [ $# -ne 0 ]; do
		if [ -e "$1" ]; then
			random="$(dd if=/dev/urandom bs=512 count=1 2>/dev/null| md5sum -b | awk '{print $1}')"
			basename=$(basename "$1")
			dirname=$(dirname "$1")
			echo "$dirname/$basename mv to $dirname/$random" 
			mv "$dirname/$basename" "$dirname/$random"
		else
			echo "$1 nie istnieje"
		fi
		shift
	done
else
	echo "Uzycie: $0 pliki_lub_katalogi_do_przemianowania"
fi
