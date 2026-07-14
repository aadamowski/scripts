#!/usr/bin/env bash
set -euo pipefail
# Author: Aleksander Adamowski
#
# Description: Rescans the SCSI/FC bus.

host_number="$1"
printf "1\n" > /sys/class/fc_host/host${host_number}/issue_lip
printf "- - -\n" > /sys/class/scsi_host/host${host_number}/scan
