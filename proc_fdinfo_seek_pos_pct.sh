#!/usr/bin/env bash
set -euo pipefail
# Author: Aleksander Adamowski

if [[ $# -lt 2 ]]; then
  printf "Report the seek position of a given file descriptor held open by a\n" > /dev/stderr
  printf "process with the given PID.\n" > /dev/stderr
  printf "The position is shown as a percentage of the file's size.\n" > /dev/stderr
  printf "\n" > /dev/stderr
  printf "Usage:\n" > /dev/stderr
  printf "\n" > /dev/stderr
  printf "%s pid file_descriptor_number\n" "$0" > /dev/stderr
  exit 1
fi


pid=$1
fdnum=$2

formula="$(grep ^pos: "/proc/${pid}/fdinfo/${fdnum}" | awk '{print $2}') / $(stat --format="%s" "$(readlink "/proc/${pid}/fd/${fdnum}")")"
LC_NUMERIC=C printf "%.4f%%\n" "$( (printf "scale=4\n"; printf "%s * 100\n" "${formula}") | bc )"

