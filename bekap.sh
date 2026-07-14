#!/usr/bin/env bash
set -euo pipefail
#
# Description: Creates a backup of a file in the ~/bekap directory.
# The backup is timestamped (YYYY_MM_DD_HH=MM=SS).
# Dependencies: bash, date, bzip2, basename
# Usage: ./bekap.sh <file1> [file2 ...]
# Author: Aleksander Adamowski
#
# Note: The backup is compressed using bzip2.


BACKUP_DIR="$HOME/bekap"

# Ensure backup directory exists
if [[ ! -d "$BACKUP_DIR" ]]; then
    mkdir -p "$BACKUP_DIR" || { printf "Nie udalo sie utworzyc katalogu %s\n" "$BACKUP_DIR" >&2; exit 1; }
fi

if [[ $# -lt 1 ]]; then
    printf "Uzycie: %s <plik1> [plik2 ...]\n" "$0" >&2
    exit 1
fi

while [[ $# -gt 0 ]]; do
    FILE="$1"
    
    if [[ -e "$FILE" ]]; then
        if [[ -f "$FILE" ]]; then
            TIMESTAMP=$(date +%Y_%m_%d_%H=%M=%S)
            FILENAME=$(basename "$FILE")
            DEST_FILE="$BACKUP_DIR/${FILENAME}.${TIMESTAMP}.bz2"
            
            if bzip2 -c "$FILE" > "$DEST_FILE"; then
                printf "Kopia zapasowa utworzona: %s -> %s\n" "$FILE" "$DEST_FILE"
            else
                printf "Blad podczas tworzenia kopii zapasowej dla pliku: %s\n" "$FILE" >&2
                exit 1
            fi
        else
            printf "Plik %s nie istnieje lub nie jest plikiem zwykłym\n" "$FILE" >&2
            exit 1
        fi
    else
        printf "Plik %s nie istnieje\n" "$FILE" >&2
        exit 1
    fi
    shift
done
