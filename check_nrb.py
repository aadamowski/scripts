#!/usr/bin/env python3
#
# Description: Validates a Polish bank account number (NRB/IBAN).
# Dependencies: python3
# Usage: echo <nrb_or_iban> | ./check_nrb.py
# Author: Aleksander Adamowski

import sys

def iban_letter2num(letter):
    return str(ord(letter.upper()) - ord('A') + 10)

def check_nrb(num):
    if len(num) == 26:
        num = 'PL' + num
    
    if len(num) != 28:
        return False, f"Nieprawidlowa dlugosc numeru - powinno byc 28 znakow razem z kodem kraju, jest {len(num)}"
    
    try:
        # Rearrange for modulo 97 check: BBAN + CountryCodeDigits + CheckDigits
        # num[0:2] is country code (e.g. 'PL')
        # num[2:4] is check digits
        # num[4:] is BBAN
        
        rearranged = num[4:] + iban_letter2num(num[0]) + iban_letter2num(num[1]) + num[2:4]
        
        if int(rearranged) % 97 == 1:
            return True, num
        else:
            return False, "Zla suma kontrolna"
    except ValueError as e:
        return False, f"Blad przetwarzania: {e}"

def main():
    try:
        line = sys.stdin.readline()
        if not line:
            return
        
        num = line.strip().replace(' ', '').upper()
        if not num:
            return

        is_valid, result = check_nrb(num)
        if is_valid:
            print(f"OK: {result}")
        else:
            print(f"BŁĄD: {result}")
            sys.exit(1)
    except Exception as e:
        print(f"Wystapil blad: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()


