#!/usr/bin/env perl
#
# Description: Monitors a growing log file for a regex pattern and executes a command upon matching.
# Dependencies: perl, File::Tail
# Usage: perl monitor_logfile_cmd.pl [-n] <logfile> '<regexp>' '<shell_command>'
# Author: Aleksander Adamowski
#
# Options:
# -n: Exit after the first match.

use strict;
use warnings;
use File::Tail;
use Getopt::Std;

my %opts;
getopts('n', \%opts);

if (scalar(@ARGV) < 3) {
    print STDERR "Uzycie:\n";
    print STDERR " $0 [-n] plik_logu 'wzorzec regexp' 'polecenie powloki'\n";
    die "Nieprawidlowa skladnia.\n";
}

my $log_file = $ARGV[0];
my $regexp_source = $ARGV[1];
my $command = $ARGV[2];

my $regexp = qr/$regexp_source/;

my $file = File::Tail->new(
    name => $log_file,
    interval => 1,
    maxinterval => 2,
    ignore_nonexistant => 1
);

while (defined(my $line = $file->read)) {
    if ($line =~ /$regexp/) {
        system($command);
        if ($opts{n}) {
            exit 0;
        }
    }
}

