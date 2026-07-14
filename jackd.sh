#!/usr/bin/env bash
set -euo pipefail
# Author: Aleksander Adamowski

jackd -v -d alsa -d hw:0,0
