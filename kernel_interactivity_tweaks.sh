#!/usr/bin/env bash
set -euo pipefail
# Author: Aleksander Adamowski
#
# Description: Tweaks kernel settings for improved interactivity.

for cpu_governor in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
  printf "performance\n" > "${cpu_governor}"
done

# minimum 1000 ms working set lifetime before it can be evicted
printf "1000\n" > /sys/kernel/mm/lru_gen/min_ttl_ms

# Don't allow more that 5% of available memory in unflushed dirty pages
# respectively for process that is actively writing (default: 10%) and for
# kernel bg flusher (default: 20%):
printf "5\n" > /proc/sys/vm/dirty_ratio
printf "5\n" > /proc/sys/vm/dirty_background_ratio
