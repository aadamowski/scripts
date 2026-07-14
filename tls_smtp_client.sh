#!/usr/bin/env bash
set -euo pipefail
#
# Description: Uses openssl s_client to connect to an SMTP server via STARTTLS.
# Dependencies: bash, openssl
# Usage: ./tls_smtp_client.sh <host:port>
# Author: Aleksander Adamowski
#
# Note: This is a simple wrapper for openssl s_client with STARTTLS.


if [[ $# -eq 1 ]]; then
    openssl s_client -starttls smtp -connect "$1"
else
    printf "Uzycie: %s host:port\n" "$0" >&2
    printf "n.p.:\n" >&2
    printf "%s nmail.altkom.pl:25\n" "$0" >&2
    exit 1
fi

