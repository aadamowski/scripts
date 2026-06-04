#!/bin/bash

for cpu_governor in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
  echo performance > "${cpu_governor}"
done

# minimum 1000 ms working set lifetime before it can be evicted
echo 1000 > /sys/kernel/mm/lru_gen/min_ttl_ms

# Don't allow more that 5% of available memory in unflushed dirty pages
# respectively for process that is actively writing (default: 10%) and for
# kernel bg flusher (default: 20%):
echo 5 > /proc/sys/vm/dirty_ratio
echo 5 > /proc/sys/vm/dirty_background_ratio

