#!/usr/bin/env bash
set -euo pipefail
# Author: Aleksander Adamowski
# pią wrz 17 12:35:17 CEST 2004
# Wyswietla CSR-a x509

openssl req -in "$1" -text
