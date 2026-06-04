#!/usr/bin/python
import sys

def check_pesel(pesel):
	sum, ct = 0, [1, 3, 7, 9, 1, 3, 7, 9, 1, 3, 1]
	for i in range(11):
		sum += (int(pesel[i]) * ct[i])
	return (str(sum)[-1] == '0')

line = sys.stdin.readline()
if check_pesel(line):
	print "PESEL poprawny"
else:
	print "PESEL NIEPOPRAWNY!"
