#!/usr/bin/env perl
#
# Description: Computes an optimal distribution of files in the current directory
#              for burning to multiple DVD disks using a knapsack algorithm.
# Dependencies: perl, Filesys::DiskUsage, Algorithm::Knapsack, Getopt::Long, Pod::Usage
# Usage: perl knapsack_for_DVD.pl [-s SIZE] [-t TIME] [-a ALGO]
# Author: Aleksander Adamowski
#
# Options:
# -s SIZE: Set the size of a single disk in bytes (default: 8540000000)
# -t TIME: Set the maximum time of execution in seconds (default: 30)
# -a ALGO: Choose optimization algorithm: 'random' (default) or 'brute_force'
#
use strict;
use warnings;
use Getopt::Long;
use Pod::Usage;
use Filesys::DiskUsage qw/du/;
use Data::Dumper;
use Algorithm::Knapsack;

my $man = 0;
my $help = 0;
my $disk_size = 8540000000;
my $max_time = 30;
my $optimization_algorithm = 'random';

GetOptions(
    'help|?'      => \$help,
    'man'         => \$man,
    'size|s=i'    => \$disk_size,
    'time|t=i'    => \$max_time,
    'algo|a=s'    => \$optimization_algorithm
) or pod2usage(2);

pod2usage(1) if $help;
pod2usage(-exitstatus => 0, -verbose => 2) if $man;

opendir(my $dir_fh, '.') or die "can't opendir .: $!";
my @entries = readdir($dir_fh);
closedir $dir_fh;

my %entry_sizes = du( { 'make-hash' => 1 }, @entries );

my %size_entries;

# If sizes aren't unique, we'll get messed up results. There's nothing we can do...
foreach my $entry (keys %entry_sizes) {
    if (defined($size_entries{$entry_sizes{$entry}})) {
        $size_entries{$entry_sizes{$entry}} .= "|$entry";
    } else {
        $size_entries{$entry_sizes{$entry}} = $entry;
    }
}

my @sizes = values %size_entries;

my $knapsack = Algorithm::Knapsack->new(
    capacity => $disk_size,
    weights  => \@sizes,
);

print STDERR "Please wait, computing optimal contents...\n";
$knapsack->compute();

my $solnr = 1;
foreach my $solution ($knapsack->solutions()) {
    print "Solution $solnr:\n";
    my $sum = 0;
    foreach my $size_index (@{$solution}) {
        my $size = $sizes[$size_index];
        print "\t$size\t".$size_entries{$size}."\n";
        $sum += $size;
    }
    print "Sum: $sum\n";
    $solnr++;
}

=head1 NAME

knapsack_for_DVD.pl - compute close to optimal distribution of contents
of the current dir for burning to multiple DVD disks

=head1 SYNOPSIS

knapsack_for_DVD.pl [options]

=head1 OPTIONS

=over 8

=item B<-help>

Print a brief help message and exits.

=item B<-man>

Prints the manual page and exits.

=item B<-size, -s SIZE>

Sets the size of a single disk in bytes.

=item B<-time, -t TIME>

Sets the maximum time of execution in seconds.

=item B<-algo, -a ALGO>

Chooses the optimization algorithm to use. Possible algorithms are:

random (default)

brute_force

=back

=head1 DESCRIPTION

This script computes close to optimal distribution of contents
of the current dir among multiple equal size buckets.

Use it to optimally distribute content for burning to multiple disks (e.g. 
DVDs).

Note that the problem is NP-complete so only the approximate solution may be 
possible to find in reasonable time.

=head1 Typical disk sizes

Typical sizes of DVD writable disks:

 Disk Type   Data sectors(2048 B each)  bytes          GB  GiB
 DVD-R (SL)  2,298,496                  4,707,319,808  4.7 4.384
 DVD+R (SL)  2,295,104                  4,700,372,992  4.7 4.378
 DVD-R DL    4,171,712                  8,543,666,176  8.5 7.957
 DVD+R DL    4,173,824                  8,547,991,552  8.5 7.961

Source: Wikipedia (http://en.wikipedia.org/wiki/DVD#DVD_capacity).

=cut


