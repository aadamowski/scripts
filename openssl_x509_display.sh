#!/usr/bin/env bash
set -euo pipefail
# Author: Aleksander Adamowski
# Wyswietla zawartosc certyfikatu x509

if [[ $# -eq 0 ]]; then
    printf "%s\n" "Usage: $0 <certificate_file>"
    exit 1
fi

openssl x509 -in "$1" -text
