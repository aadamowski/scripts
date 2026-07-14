#!/usr/bin/env python3
#
# Description: Unquotes URL-encoded strings.
# Dependencies: python3
# Usage: echo "hello%20world" | ./unquote.py
# Author: Aleksander Adamowski

import urllib.parse
import fileinput
import sys

def main():
    try:
        for line in fileinput.input():
            print(urllib.parse.unquote(line).rstrip())
    except Exception as e:
        print(f"Wystapil blad: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()
