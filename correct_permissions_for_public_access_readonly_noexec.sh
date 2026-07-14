#!/usr/bin/env bash
set -euo pipefail
#
# Description: Sets permissions for public access: read-only and no-execute.
# Dependencies: bash, chmod
# Usage: ./correct_permissions_for_public_access_readonly_noexec.sh
# Author: Aleksander Adamowski
#
# Note: Applies chmod -R ugo-x,u=rwX,go=rX to the current directory.


chmod -R ugo-x,u=rwX,go=rX .

