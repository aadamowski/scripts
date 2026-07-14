#!/usr/bin/env perl
#
# Description: Decodes URL-encoded strings.
# Dependencies: perl
# Usage: echo "hello%20world" | ./url_decode.pl
# Author: Aleksander Adamowski

use strict;
use warnings;

while (<>) {
    s/\%([A-Fa-f0-9]{2})/pack('C', hex($1))/eg;
    print;
}

