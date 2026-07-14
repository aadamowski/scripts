#!/usr/bin/env perl
#
# Description: Encodes strings to URL-encoded format.
# Dependencies: perl
# Usage: echo "hello world" | ./url_encode.pl
# Author: Aleksander Adamowski

use strict;
use warnings;

while (<>) {
    s/([^A-Za-z0-9])/sprintf("%%%02X", ord($1))/eg;
    print;
}
