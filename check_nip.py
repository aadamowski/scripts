#!/usr/bin/python
import sys

def check_nip(nip):
	sum, ct = 0, [6, 5, 7, 2, 3, 4, 5, 6, 7]
	for i in range(9):
		sum += (int(nip[i]) * ct[i])
	return ((sum%11) == int(nip[9]))

line = sys.stdin.readline()
if check_nip(line):
	print "NIP poprawny"
else:
	print "NIP NIEPOPRAWNY!"
