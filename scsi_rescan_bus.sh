#!/bin/sh

host_number="$1"
echo "1" > /sys/class/fc_host/host${host_number}/issue_lip
echo "- - -" > /sys/class/scsi_host/host${host_number}/scan

