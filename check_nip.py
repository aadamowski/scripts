#!/usr/bin/env python3
#
# Description: Validates a Polish NIP number.
# Dependencies: python3
# Usage: echo <nip> | ./check_nip.py
# Author: Aleksander Adamowski

import sys

def check_nip(nip):
    nip = nip.strip()
    if len(nip) != 10 or not nip.isdigit():
        return False
    
    weights = [6, 5, 7, 2, 3, 4, 5, 6, 7]
    total_sum = 0
    try:
        for i in range(9):
            total_sum += int(nip[i]) * weights[i]
        
        remainder = total_sum % 11
        if remainder == 10:
            return False
            
        return remainder == int(nip[9])
    except ValueError:
        return False

def main():
    try:
        line = sys.stdin.readline()
        if not line:
            return
        
        nip = line.strip()
        if not nip:
            print("Brak danych wejsciowych.")
            sys.exit(1)

        if check_nip(nip):
            print("NIP poprawny")
        else:
            print("NIP NIEPOPRAWNY!")
            sys.exit(1)
    except Exception as e:
        print(f"Wystapil blad: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()
