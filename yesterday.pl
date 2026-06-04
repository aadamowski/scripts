#!/usr/bin/perl
use POSIX qw(strftime);
my $yest=time - 60 * 60 * 24;
my $ndst = (localtime $now)[8] > 0;
my $tdst = (localtime $then)[8] > 0;
$yest -= ($tdst - $ndst) * 60 * 60;
print strftime("%F", gmtime($yest))."\n";
