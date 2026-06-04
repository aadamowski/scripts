#!/bin/sh
# by OLO
# Wed Mar 30 23:07:05 CEST 2005
# Dostraja VM dla leniwego splukiwania brudnych stron

sysctl -w vm.dirty_background_ratio=60
sysctl -w vm.dirty_ratio=80
sysctl -w vm.dirty_writeback_centisecs=9000
sysctl -w vm.dirty_expire_centisecs=9000

