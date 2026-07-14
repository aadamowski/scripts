#!/usr/bin/env bash
set -euo pipefail
# Author: Aleksander Adamowski

lsblk -o NAME,MODEL,SIZE,LABEL,FSTYPE
