#!/usr/bin/env bash
set -euo pipefail
#
# Description: Generates a random number below a given value.
# Author: Aleksander Adamowski
#
printf '%d\n' $((RANDOM*$1/32767))
