#!/usr/bin/env bash
# Author: Aleksander Adamowski
set -euo pipefail
rpm -qa --qf '%{SIZE}\t%{NAME}\n' | sort -n
