#!/bin/sh
# by OLO
# Wed Mar 30 23:07:05 CEST 2005
# Dostraja VM dla leniwego splukiwania brudnych stron

sysctl -w vm.dirty_background_ratio=30
sysctl -w vm.dirty_ratio=50
sysctl -w vm.dirty_writeback_centisecs=500
sysctl -w vm.dirty_expire_centisecs=1000

