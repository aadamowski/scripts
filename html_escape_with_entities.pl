#!/usr/bin/env perl
#
# Description: Escapes HTML entities (<, >, &, ") in the input.
# Dependencies: perl, HTML::Entities
# Usage: echo "<script>alert('hi')</script>" | ./html_escape_with_entities.pl
# Author: Aleksander Adamowski

use strict;
use warnings;
use HTML::Entities;

while (<>) {
    $_ = encode_entities($_, '<>&"');
    print;
}

