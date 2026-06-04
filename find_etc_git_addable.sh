#!/bin/sh
find ./ -type f -perm -o+r \
 -not -path '*/opt/Adobe*' \
 -not -path '*/.git*' \
 -not -path '*/ssl/*' \
 -not -name mtab \
 -not -name ld.so.cache \
 "$@"
