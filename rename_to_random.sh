#!/usr/bin/env bash
set -euo pipefail
#
# Description: Renames files to random MD5 hashes.
# Author: Aleksander Adamowski
#


if [[ $# -ge 1 ]]; then
	while [[ $# -ne 0 ]]; do
		if [[ -e "$1" ]]; then
			random="$(dd if=/dev/urandom bs=512 count=1 2>/dev/null| md5sum -b | awk '{print $1}')"
			basename=$(basename "$1")
			dirname=$(dirname "$1")
			printf "%s mv to %s\n" "$dirname/$basename" "$dirname/$random"
			mv "$dirname/$basename" "$dirname/$random"
		else
			printf "%s nie istnieje\n" "$1"
		fi
		shift
	done
else
	printf "Uzycie: %s pliki_lub_katalogi_do_przemianowania\n" "$0"
fi
