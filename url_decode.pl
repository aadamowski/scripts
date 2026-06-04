#!/usr/bin/perl -w -p
#

s/\%([A-Fa-f0-9]{2})/pack('C', hex($1))/seg;
