#!/bin/bash

set -e
set -o pipefail

if [ $# -lt 2 ]; then
  echo "Report the seek position of a given file descriptor held open by a" > /dev/stderr
  echo "process with the given PID." > /dev/stderr
  echo "The position is shown as a percentage of the file's size." > /dev/stderr
  echo > /dev/stderr
  echo "Usage:" > /dev/stderr
  echo > /dev/stderr
  echo "$0 pid file_descriptor_number" > /dev/stderr
  exit 1
fi


pid=$1
fdnum=$2

formula="$(grep ^pos: "/proc/${pid}/fdinfo/${fdnum}" | awk '{print $2}') / $(stat --format="%s" "$(readlink "/proc/${pid}/fd/${fdnum}")")"
LC_NUMERIC=C printf "%.4f%%\n" "$( (echo "scale=4"; echo "${formula} * 100") | bc)"

