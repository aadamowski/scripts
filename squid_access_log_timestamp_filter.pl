#!/usr/bin/perl -p
s/^([0-9]*)/"[".localtime($1)."]"/e
