#!/bin/sh
# by OLO
# pią wrz 17 12:35:17 CEST 2004
# Wyswietla zawartosc certyfikatu x509

openssl x509 -in "$1" -text
