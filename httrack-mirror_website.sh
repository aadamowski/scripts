#!/bin/sh

#httrack "$@" -j -%P -w -n -b1 -%h -%k -%B -C1 -P stacja.amarczuk:8080
httrack "$@" -j -%P -w -n -b1 -%h -%k -%B -C2
