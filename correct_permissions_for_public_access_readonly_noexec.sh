#!/bin/sh
#
# by OLO
# Tue Apr  8 20:24:44 CEST 2003
#

#find ./ -type f -exec chmod ugo-x {} \;
chmod -R ugo-x,u=rwX,go=rX .
