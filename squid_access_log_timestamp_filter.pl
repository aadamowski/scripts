#!/usr/bin/env perl
#
# Description: Prefixes each line with a timestamp in [Day Month Date HH:MM:SS Year] format.
# Dependencies: perl
# Usage: cat squid_access.log | ./squid_access_log_timestamp_filter.pl
# Author: Aleksander Adamowski

use strict;
use warnings;

while (<>) {
    s/^([0-9]*)/"[" . localtime($1) . "]"/e;
    print;
}
