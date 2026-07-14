#!/usr/bin/env bash
#
# Description: Displays system state information.
# Author: Aleksander Adamowski
#

set -euo pipefail

printf "=============\n"
printf "uptime:\n"
uptime
printf "=============\n"
printf "iostat:\n"
iostat
printf "=============\n"
printf "vmstat:\n"
vmstat
printf "=============\n"
printf "free:\n"
free
printf "=============\n"
printf "w:\n"
w
printf "=============\n"
printf "ps xuwa:\n"
ps xuwa
printf "=============\n"
printf "pstree -plau:\n"
pstree -plau
printf "================================\n"
printf "============= PROC =============\n"
printf "================================\n"
printf "/proc/partitions:\n"
cat /proc/partitions
printf "=============\n"
printf "/proc/swaps:\n"
cat /proc/swaps
printf "=============\n"
printf "/proc/stat:\n"
cat /proc/stat
printf "=============\n"
printf "/proc/vmstat:\n"
cat /proc/vmstat
printf "=============\n"
printf "/proc/diskstats:\n"
cat /proc/diskstats
printf "=============\n"
printf "/proc/meminfo:\n"
cat /proc/meminfo
printf "=============\n"
printf "/proc/ioports:\n"
cat /proc/ioports
printf "=============\n"
printf "/proc/iomem:\n"
cat /proc/iomem
printf "=============\n"
printf "/proc/cpuinfo:\n"
cat /proc/cpuinfo
printf "=============\n"
printf "/proc/interrupts:\n"
cat /proc/interrupts
