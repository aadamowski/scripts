#!/usr/bin/env bash
# Author: Aleksander Adamowski
set -euo pipefail

blockdev --rereadpt "$1"

