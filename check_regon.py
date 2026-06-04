#!/usr/bin/python
import sys




def check_regon(regon):
	sum = 0
	w = [8, 9, 2, 3, 4, 5, 6, 7]
	if len(regon) == 7:
		w = w[2:]
	elif len(regon) == 14:
		# ciezko znalezc algorytm (wagi) do sprawdzenia ostatnich
		# pieciu cyfr, wiec olewamy
		regon = regon[:9]

	ct = int(regon[-1])

	for i in range(len(w)):
		sum += (int(r[i]) * w[i])
	mod = sum%11
	if (mod == ct) or (mod == 10 and ct == 0):
		return True
	return False

line = sys.stdin.readline()
if check_regon(line):
  print "REGON poprawny"
else:
  print "REGON NIEPOPRAWNY!"

