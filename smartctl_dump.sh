#!/bin/sh
timestamp=$(date +%F_%H_%M_%S)
for disk in sda sdb sdc sdd; do
        smartctl -x -a /dev/${disk} > /root/smartdump_${disk}_$timestamp.txt 2>&1
done
