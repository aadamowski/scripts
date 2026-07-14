#!/usr/bin/env perl
#
# Description: Finds potential Base64 patterns by testing variations with leading spaces.
# Dependencies: perl, MIME::Base64
# Usage: echo "input" | ./base64_pattern_matcher.pl
# Author: Aleksander Adamowski

use strict;
use warnings;
use MIME::Base64;

sub main {
    while (<>) {
        chomp;
        my $input = $_;
        
        # Base64 encoding of the input
        my $shift0 = encode_base64($input);
        
        if (length($shift0) < 3) {
            print STDERR "Blad! za krotki wzorzec. Tylko wzorce liczace co najmniej 4 znaki maja sens teoretyczny, a co najmniej 6 znakow sens praktyczny.\n\n";
        } else {
            print "\n";

            # Variation 0: Original input (strip padding)
            $shift0 =~ s/=+$//;
            if (length($shift0) > 2) {
                $shift0 = substr($shift0, 0, length($shift0) - 2);
            }
            print "$shift0\n";

            # Variation 1: Adding one space at the beginning
            my $shift1 = encode_base64(" " . $input);
            $shift1 = substr($shift1, 2); # remove first 2 chars
            $shift1 =~ s/=+$//;
            if (length($shift1) > 2) {
                $shift1 = substr($shift1, 0, length($shift1) - 2);
            }
            print "$shift1\n";

            # Variation 2: Adding two spaces at the beginning
            my $shift2 = encode_base64("  " . $input);
            $shift2 = substr($shift2, 3); # remove first 3 chars
            $shift2 =~ s/=+$//;
            if (length($shift2) > 2) {
                $shift2 = substr($shift2, 0, length($shift2) - 2);
            }
            print "$shift2\n";
            print "\n";
        }
    }
}

main();
