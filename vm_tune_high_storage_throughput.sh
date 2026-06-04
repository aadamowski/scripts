#!/bin/sh
# by OLO
# Wed Mar 30 23:07:05 CEST 2005
# Dostraja VM i urzadzenia blokowe dla wiekszej przepustowosci kosztem czasu reakcji


/root/bin/vm_tune_lazy-dirty.sh

devices="sda sdb sdc"
for device in $devices; do
  # default: 6
  echo 2 > /sys/block/${device}/queue/iosched/antic_expire
  # default: 500
  echo 1500 > /sys/block/${device}/queue/iosched/read_batch_expire
  # default: 125
  echo 500 > /sys/block/${device}/queue/iosched/write_batch_expire

  # default: 125
  echo 500 > /sys/block/${device}/queue/iosched/read_expire
  # default: 250
  echo 750 > /sys/block/${device}/queue/iosched/write_expire

  # default: 128
  #echo 512 > /sys/block/${device}/queue/nr_requests
  # default: 128
  echo 2048 > /sys/block/${device}/queue/read_ahead_kb
done; 

