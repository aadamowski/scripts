#!/usr/bin/python

import urllib2
import fileinput

for line in fileinput.input():
	print urllib2.unquote(line).rstrip()
