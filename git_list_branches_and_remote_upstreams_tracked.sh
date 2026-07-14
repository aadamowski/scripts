#!/usr/bin/env bash
set -euo pipefail
# Author: Aleksander Adamowski

git for-each-ref refs/heads --format='%(refname:short) %(upstream:short)'
