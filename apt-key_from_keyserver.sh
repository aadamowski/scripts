#!/usr/bin/env bash
set -euo pipefail
#
# Description: Imports a GPG key from a keyserver and adds it to apt.
# Dependencies: bash, gpg, apt-key
# Usage: ./apt-key_from_keyserver.sh <key_id>
# Author: Aleksander Adamowski
#
# Note: apt-key is deprecated in many modern distributions.


if [[ $# -eq 1 ]]; then
    gpg --keyserver subkeys.pgp.net --recv "$1" && gpg --export --armor "$1" | sudo apt-key add -
else
    printf "Uzycie: %s <key_id>\n" "$0" >&2
    exit 1
fi


