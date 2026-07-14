#!/usr/bin/env perl
#
# Description: Prints the date of yesterday in YYYY-MM-DD format.
# Dependencies: perl (Time::Piece)
# Usage: perl yesterday.pl
# Author: Aleksander Adamowski

use strict;
use warnings;
use Time::Piece;

sub main {
    my $now = localtime;
    my $yesterday = $now - (24 * 60 * 60);
    print $yesterday->strftime('%Y-%m-%d') . "\n";
}

main();
