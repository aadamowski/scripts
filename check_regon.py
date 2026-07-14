#!/usr/bin/env python3
#
# Description: Validates a Polish REGON number.
# Dependencies: python3
# Usage: echo <regon> | ./check_regon.py
# Author: Aleksander Adamowski

import sys

def check_regon(regon):
    regon = regon.strip()
    if not regon.isdigit():
        return False
    
    length = len(regon)
    if length == 9:
        weights = [8, 9, 2, 3, 4, 5, 6, 7]
    elif length == 14:
        weights = [8, 9, 2, 3, 4, 5, 6, 7, 1, 8, 9, 2, 3]
    else:
        return False
    
    total_sum = 0
    for i in range(len(weights)):
        total_sum += int(regon[i]) * weights[i]
    
    checksum = total_sum % 10
    return checksum == int(regon[-1])

def main():
    try:
        line = sys.stdin.readline()
        if not line:
            return
        
        regon = line.strip()
        if not regon:
            print("Brak danych wejsciowych.")
            sys.exit(1)

        if check_regon(regon):
            print("REGON poprawny")
        else:
            print("REGON NIEPOPRAWNY!")
            sys.exit(1)
    except Exception as e:
        print(f"Wystapil blad: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()


