#!/bin/bash

printf '%.0s=' {1..120}
echo 
free -m
printf '%.0s-' {1..120}
echo 
uptime
printf '%.0s-' {1..120}
echo
vmstat -w
printf '%.0s=' {1..120}
echo
grep -E "Dirty:|Writeback:" /proc/meminfo | awk '{
    if ($1 == "Dirty:") print $0 " # Memory pages modified in RAM that are waiting to be flushed to disk.";
    else if ($1 == "Writeback:") print $0 " # Memory pages that are actively being transferred to the storage device right now."
}'
printf '%.0s=' {1..120}
echo
