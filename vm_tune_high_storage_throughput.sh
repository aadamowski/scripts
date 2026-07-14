#!/usr/bin/env bash
set -euo pipefail
# Author: Aleksander Adamowski
#
# Description: Tunes VM and block devices for higher throughput at the cost of response time.

/root/bin/vm_tune_lazy-dirty.sh

devices="sda sdb sdc"
for device in $devices; do
  # default: 6
  printf "2\n" > /sys/block/${device}/queue/iosched/antic_expire
  # default: 500
  printf "1500\n" > /sys/block/${device}/queue/iosched/read_batch_expire
  # default: 125
  printf "500\n" > /sys/block/${device}/queue/iosched/write_batch_expire
  # default: 125
  printf "500\n" > /sys/block/${device}/queue/iosched/read_expire
  # default: 250
  printf "750\n" > /sys/block/${device}/queue/iosched/write_expire

  # default: 128
  #printf "512\n" > /sys/block/${device}/queue/nr_requests
  # default: 128
  printf "2048\n" > /sys/block/${device}/queue/read_ahead_kb
done
