#!/usr/bin/env bash
set -euo pipefail
# Author: Aleksander Adamowski
#
# Description: Dostraja VM dla leniwego splukiwania brudnych stron

sysctl -w vm.dirty_background_ratio=30
sysctl -w vm.dirty_ratio=50
sysctl -w vm.dirty_writeback_centisecs=500
sysctl -w vm.dirty_expire_centisecs=1000
