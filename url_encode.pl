#!/usr/bin/perl -w -p
#

s/([^A-Za-z0-9])/sprintf("%%%02X", ord($1))/seg;
