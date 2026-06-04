#!/usr/bin/perl -w
# by OLO
# Tue Aug 16 11:41:26 CEST 2005
# Monitoruje przyrastajacy plik logow oczekujac na pojawienie sie wzorca.
# Po pojawieniu sie wzorca wykonuje polecenie.
use strict;
use File::Tail;
use Getopt::Std;

$| = 1;

our($opt_n);
getopts('n');

if (scalar(@ARGV) < 3) {
  print STDERR <<EOD
Uzycie:
 $0 [-n] plik_logu 'wzorzec regexp' 'polecenie powloki'
EOD
;
	die("Nieprawidlowa skladnia.\n");
}

#print "File: ".$ARGV[0]."\n";
#print "Regexp: ".$ARGV[1]."\n";
#print "CMD: ".$ARGV[2]."\n";

my $regexp_source = $ARGV[1];
my $regexp = qr/$regexp_source/;

my $file=File::Tail->new(name => $ARGV[0], interval => 1, maxinterval => 2, ignore_nonexistant => 1);
my $line;
while (defined($line=$file->read)) {
  if ($line =~ /$regexp/) {
    system($ARGV[2]);
    if (! $opt_n) {
      exit 0;
    }
  }
}

