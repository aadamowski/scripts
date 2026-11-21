#!/bin/sh

# Note: must be GNU parallel, not moreutils parallel
parallel --timeout 30 --line-buffer ::: \
  "ping -6 -c 3 ff02::1%wlp3s0" \
  "fping -a -g 192.168.1.0/24 2>/dev/null"

# Wait for FAILED entries to get cleaned up
sleep 5

ip -4 neigh
ip -6 neigh

