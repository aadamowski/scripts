#!/usr/bin/perl -w
#
# See perldoc documentation at the end of the script
# or launch it with the -help option.


use Getopt::Long;
use Pod::Usage;
my $man = 0;
my $help = 0;
my $disk_size = 8540000000;
# About half a minute on a 2 GHz CPU:
#my $max_rounds = 32768;
# in seconds:
my $max_time = 30;
# May be 'brute_force' or 'random':
#my $optimization_algorithm='brute_force';
my $optimization_algorithm='random';

GetOptions(
		'help|?' => \$help,
		man => \$man,
		'size|s=s' => \$disk_size,
		'time|t=s' => \$max_time,
		'algo|a=s' => \$optimization_algorithm
)  or pod2usage(2);
pod2usage(1) if $help;
pod2usage(-exitstatus => 0, -verbose => 2) if $man;



use strict;
use Filesys::DiskUsage qw/du/;
use Data::Dumper;
use Algorithm::Knapsack;

opendir(DIR, '.') || die "can't opendir .: $!";
my @entries = readdir(DIR);
closedir DIR;

my %entry_sizes = du( { 'make-hash' => 1 }, @entries );
#print Dumper(\%entry_sizes);

my %size_entries;

# If sizes aren't unique, we'll get messed up results. There's nothing we can do...
foreach my $entry (keys %entry_sizes ) {
	if (defined($size_entries{$entry_sizes{$entry}})) {
		$size_entries{$entry_sizes{$entry}} .= "|$entry";
	} else {
		$size_entries{$entry_sizes{$entry}} = $entry;
	}
}

my @sizes = values %entry_sizes;

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

bucketize_for_DVD.pl - compute close to optimal distribution of contents
of the current dir for burning to multiple DVD disks

=head1 SYNOPSIS

bucketize_for_DVD.pl [options]

Options:
       -help            brief help message
       -man             full documentation

=head1 OPTIONS

=over 8

=item B<-help>

Print a brief help message and exits.

=item B<-man>

Prints the manual page and exits.

=item B<-size, -s SIZE>

Sets the size of a single disk in bytes.

=item B<-time, -t SIZE>

Sets the maximum time of execution in seconds.

=item B<-algo, -a SIZE>

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
