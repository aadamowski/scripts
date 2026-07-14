#!/usr/bin/env perl
#
# Description: Converts DOS line endings (\r\n) to Unix line endings (\n).
# Dependencies: perl
# Usage: perl dos_2_unix_endlines.pl -i <file1> [file2 ...]
# Author: Aleksander Adamowski
#
# Note: This script processes files from STDIN or files provided as arguments.

use strict;
use warnings;

while (<>) {
    s/\r\n/\n/g;
    print;
}

