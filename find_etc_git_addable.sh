#!/bin/sh
# Vulnerable to leaks due to only considering leaf file's permission bits:
#find ./ -type f -perm -o+r \
sudo -u nobody find ./ -type f -readable \
 -not -path '*/opt/Adobe*' \
 -not -path '*/.git*' \
 -not -path '*/ssl/*' \
 -not -name mtab \
 -not -name ld.so.cache \
 "$@"
