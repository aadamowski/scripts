#!/bin/sh
# Poor person's ntpdate using timestamps reported in HTTP headers by google.com.
# For use in constrained environments where NTP client cannot run.

date -s "$(wget -S --spider "http://www.google.com/" 2>&1 | grep -E '^[[:space:]]*[dD]ate:' | sed 's/^[[:space:]]*[dD]ate:[[:space:]]*//' | tail -n 1)"
