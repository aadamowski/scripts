#!/usr/bin/env python3
#
# Description: Applies ROT13 encoding to input text.
# Dependencies: python3
# Usage: echo "hello" | ./rot13.py
# Author: Aleksander Adamowski

import sys
import codecs

def main():
    try:
        for line in sys.stdin:
            print(codecs.encode(line, 'rot_13'), end='')
    except Exception as e:
        print(f"Wystapil blad: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()
