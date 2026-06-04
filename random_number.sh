#!/bin/sh
#dd if=/dev/urandom bs=1 count=1 2>/dev/null | hexdump -e '"%02d\n"'
#dd if=/dev/urandom bs=1 count=1 2>/dev/null | hexdump -e '"%02d\n"' | sed -e 's/^0*//'
dd if=/dev/urandom bs=1 count=1 2>/dev/null | hexdump -e '"%02d\n"' | perl -pe 's/^0*(.+)/\1/'
