#!/bin/sh
dpkg-query -W -f '${Installed-Size}\t${Package}\n' | sort -n

