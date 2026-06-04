#!/usr/bin/python
import sys
 
def iban_letter2num(letter):
	return str(ord(letter) - ord('A') + 10)

num = sys.stdin.readline().strip().replace(' ', '')
if len(num) == 26:
	num = 'PL'+num
if len(num) != 28:
	print "Nieprawidlowa dlugosc numeru - powinno byc 28 znakow razem z kodem kraju, jest %d" % len(num)
else:
	print num
	num = num[4:] + iban_letter2num(num[0]) + iban_letter2num(num[1]) + num[2:4]
	n = int(num)
	if n % 97 == 1:
		print "ok"
	else:
		print "zla suma kontrolna"

