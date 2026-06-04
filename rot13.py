#!/usr/bin/python

import sys
for line in sys.stdin.readlines():
	print line.encode('rot13'),
