#!/usr/bin/env perl
#
# Description: Generates a unique list of files from strace output for /etc/readahead.files.
# Dependencies: perl, strace
# Usage: strace ... -o OUTPUT_FILENAME && cat OUTPUT_FILENAME | ./strace_open_extract_names_for_readahead.pl [-m] [-t]
# Author: Aleksander Adamowski
#
# Notes:
# On STDIN, accepts a file generated with the following commandline:
# strace -f -F -p KDM_OR_GDM_PID1 \
#    -p KDM_OR_GDM_PID2 \
#    -p KDM_OR_GDM_PID3 \
#     ... \
#    -e trace=open,process -o OUTPUT_FILENAME
#
# You have to specify the PIDs of processes that will open files (or whose children will read files)
# during the graphic environment startup. In KDM, this is the PID of X, and both kdm processes.
# The "pstree -plau" command is very useful to determine those PIDs.
#
# Strace should be run immediately after system startup, before logging in through GDM/KDM,
# and interrupted right after the environment finishes starting up.
#
# On STDOUT, outputs a list of unique files that are to be preloaded by readahead.
#
use strict;
use warnings;
use Getopt::Std;

my %seen;
my $size;
my $total_size = 0;
my $total_mem = 0;

my %opts;
getopts('mt', \%opts);

# Get total memory from vmstat
open my $vmstat_fh, '-|', 'vmstat -sK' or die "Cannot run vmstat: $!";
while (<$vmstat_fh>) {
    if (/^\s*([0-9]+)\s+total memory$/) {
        $total_mem = $1 * 1024;
        last;
    }
}
close $vmstat_fh;

while (<>) {
    # Omit opens from proc, dev, sys, home:
    if (/(?:open|execve)\(\"([^"]+)\"/) {
        my $path = $1;
        if ($path !~ m{^/proc/} && 
            $path !~ m{^/dev/} && 
            $path !~ m{^/sys/} && 
            $path !~ m{^/[^/]} && 
            $path !~ m{^/home/}) {
            
            # only output unique filenames:
            if (-f $path && ! ($seen{$path}++)) { 
                # compute size to allow limiting:
                my @stat = stat($path);
                if (@stat) {
                    $size = $stat[7];
                    $total_size += $size;
                }
                
                # exit if we have exceeded half of total available RAM:
                last if ($total_size > ($total_mem / 2));
                print "$path\n";
            }
        }
    }
}

print "Total mem: $total_mem\n" if $opts{m};
print "Total size: $total_size\n" if $opts{t};



