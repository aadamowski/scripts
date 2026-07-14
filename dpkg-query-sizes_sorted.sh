#!/usr/bin/env bash
set -euo pipefail
#
# Description: Lists installed packages sorted by their size.
# Dependencies: bash, dpkg-query, sort
# Usage: ./dpkg-query-sizes_sorted.sh
# Author: Aleksander Adamowski
#
# Note: Uses dpkg-query to get the installed size of each package.

dpkg-query -W -f '${Installed-Size}\t${Package}\n' | sort -n

