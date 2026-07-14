#!/usr/bin/env bash
set -euo pipefail
# Author: Aleksander Adamowski

git for-each-ref --sort=-committerdate refs/
