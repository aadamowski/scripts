#!/usr/bin/env bash
set -euo pipefail
# Author: Aleksander Adamowski
# Dostraja VM dla leniwego splukiwania brudnych stron

sysctl -w vm.dirty_background_ratio=60
sysctl -w vm.dirty_ratio=80
sysctl -w vm.dirty_writeback_centisecs=9000
sysctl -w vm.dirty_expire_centisecs=9000

