#!/usr/bin/env bash
set -euo pipefail
# Author: Aleksander Adamowski

xxd -r -p | openssl asn1parse -inform DER
