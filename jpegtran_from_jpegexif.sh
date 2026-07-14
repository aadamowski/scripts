#!/usr/bin/env bash
set -euo pipefail
# Author: Aleksander Adamowski
#
# Description: Rotates JPEG images based on EXIF orientation.

for jpg in "$@"; do
    jhead -autorot -ft "$jpg"
done
