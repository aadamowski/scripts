#!/bin/sh
# by OLO
# skrypt tworzy kopie zapasowa pliku w wydzielonym katalogu ~/bekap.
# kopia tworrzona jest z dopiskiem - numerem wersji pliku,
# tworzonym z daty i czasu wykonania (z dokladnoscia do 1 sekundy)

if [ $# -ge 1 ]; then
	while [ $# -ne 0 ]; do
		if [ -e "$1" ]; then
			curdate=$(date +%F_%H=%M=%S)
			basename=$(basename "$1")
			mv -i "$1" "$1.${curdate}"
			bzip2 "$1.${curdate}"
		else
			echo "plik $1 nie istnieje"
		fi
	shift
	done
else
	echo "Uzycie: $0 plik_do_zachowania"
fi

