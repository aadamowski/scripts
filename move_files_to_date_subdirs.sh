#!/bin/sh


find ./ -maxdepth 1 -type f -printf '%f\0%T+\n' | \
perl -pe '
BEGIN {
use strict;
use File::Copy;
}
{
$_ =~ /^([^\0]+)\0(.*)$/;
my $filename = $1;
my $timestamp = $2;
$_ = "";
$timestamp =~ /^([0-9]{4}-[0-9]{2}-[0-9]{2})\+/;
my $date = $1;
#print "$filename:\n$date\n";
my $destdir = undef;
if (-d $date) {
	$destdir = $date;
} else {
 if (-e $date) {
	print STDERR "ERROR: entry \"$date\" already exists and is not a directory!\n";
 } else {
	mkdir $date;
	$destdir = $date;
 }
}
if (defined($destdir)) {
	move ($filename, $destdir);
}
}
'
