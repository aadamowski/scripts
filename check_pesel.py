#!/usr/bin/env python3
#
# Description: Checks if a given PESEL number is valid.
# Dependencies: python3
# Usage: echo <pesel> | ./check_pesel.py
# Author: Aleksander Adamowski

import sys

def check_pesel(pesel):
    """
    Validates a PESEL number using the standard checksum algorithm.
    """
    pesel = pesel.strip()
    if len(pesel) != 11 or not pesel.isdigit():
        return False
    
    weights = [1, 3, 7, 9, 1, 3, 7, 9, 1, 3, 1]
    total_sum = 0
    try:
        for i in range(11):
            total_sum += int(pesel[i]) * weights[i]
        return (total_sum % 10 == 0)
    except ValueError:
        return False

def main():
    try:
        line = sys.stdin.readline()
        if not line:
            return
        
        pesel = line.strip()
        if not pesel:
            print("Brak danych wejsciowych.")
            sys.exit(1)

        if check_pesel(pesel):
            print("PESEL poprawny")
        else:
            print("PESEL NIEPOPRAWNY!")
            sys.exit(1)
    except Exception as e:
        print(f"Wystapil blad: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()
