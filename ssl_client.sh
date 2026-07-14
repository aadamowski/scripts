#!/usr/bin/env bash
set -euo pipefail
# Author: Aleksander Adamowski

openssl s_client -CApath /etc/ssl/cacerts/ -connect $@
