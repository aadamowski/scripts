#!/usr/bin/perl -w
# by Aleksander Adamowski
# Tue Apr 19 18:43:23 CEST 2005
#
# A script to generate a list for /etc/readahead.files.
# 
#
# On STDIN, accepts a file generated with the following commandline:
#strace -f -F -p KDM_OR_GDM_PID1 \
#	-p KDM_OR_GDM_PID2 \
#	-p KDM_OR_GDM_PID3 \
#	 ... \
#	-e trace=open,process -o OUTPUT_FILENAME
#
# You have to specify the PIDs of processes that will open filesr
# (or whose children will read files)  during the graphic environment
# startup. In KDM, this is the PID of X, and both kdm processes.
# The "pstree -plau" command is very useful to determine those PIDs.
#
# Strace should be run immediately after system startup, before
# logging in through GDM/KDM, and interrupted right after 
# the environment finishes starting up (you may also wish to launch
# your favourite applications - but I rather suggest putting them into
# Autorun, so they are indeed the ones that are always launched).
#
# On STDOUT, outputs a list of unique files that are to be preloaded
# by readahead. Put that list into /etc/readahead.files on Fedora Core.

use strict;
use Getopt::Std;

my %seen;
my $size;
my $total_size;
my $total_mem;

our ($opt_m, $opt_t);
getopts('mt');

open VMSTAT, 'vmstat -sK|';
while (<VMSTAT>) {
	if (/^\s*([0-9]+)\s+total memory$/) {
		$total_mem = $1 * 1024;
	}
}
close VMSTAT;
while (<>) {
	# Omit opens from proc, dev, sys, home:
	if ((/open\(\"([^"]+)\"/ || /execve\(\"([^"]+)\"/) &&
			$1 !~ qr(^/proc/) &&
			$1 !~ qr(^/dev/) &&
			$1 !~ qr(^/sys/) &&
			$1 !~ qr(^[^/]) &&
			$1 !~ qr(^/home/)) {
		# only output unique filenames:
		if (-f $1 && ! ($seen{$1}++)) { 
			# compute size to allow limiting:
			$size = ((stat("$1"))[7]);
			$total_size += $size if defined($size);
			# exit if we have exceeded half of total available RAM:
			last if ($total_size > ($total_mem /2));
			print $1."\n";
		} 
	}
}
if ($opt_m) { print "Total mem: $total_mem\n"; }
if ($opt_t) { print "Total size: $total_size\n"; }

