#!/usr/bin/perl
# by OLO
# pią cze 25 14:29:24 CEST 2004
# 1) Przeszukuje rekrsywnie podkatalogi, metoda DFS
# 2) Sprawdza, czy nazwa obiektu pasuje do wzorca (arg 1)
# 2) Jesli tak, dokonuje okreslonej substytucji (arg 2)


use strict;
use Fcntl ':mode';
use Data::Dumper;

my $debug = 1;

my $pattern;
my $subst;

if ($#ARGV >= 1) {
  $pattern= qr/$ARGV[0]/;
  $subst = $ARGV[1];
} else {
  die "Przeszukuje rekursywnie biezacy podkatalog i przemianowuje zawartosc.\nUzycie:\n$0 wzorzec_PCRE substytucja_PCRE \nPrzyklad:\n$0 '\\.doc' '.ole'\n";
}

my $dirname = '.';
my $mode = (stat($dirname))[2];

if (S_ISDIR($mode)) {
  if ($debug) { print "$dirname to katalog.\n"; }
  descend($dirname);
}

sub descend {
  my $dirname = shift;
  opendir DH, $dirname;
  my @descend_list;
  my @process_list;
  my $entry;
  my $pathname;
  while ($entry = readdir(DH)) {
    if ($entry !~ '^\.$' && $entry !~ '^\.\.$') {
      $pathname = $dirname.'/'.$entry;
      my $mode = (stat($pathname))[2];

      if (S_ISDIR($mode)) {
        push @descend_list, $pathname;
        #descend($entry);
      } elsif (-f $pathname) {
        push @process_list, $pathname;
      }

    }
  }
  closedir DH;
  foreach $pathname (@process_list) {
    process($pathname);
  }
  foreach my $subdir (@descend_list) {
    descend($subdir);
    process($subdir);
  }
}

sub process {
  my $pathname = shift;
  if ($debug) { print "przetwarzanie $pathname\n"; }
  if ($pathname =~ /$pattern/) {
    if ($debug) { print "$pathname pasuje do wzorca $pattern, dokonuje substytucji s/$pattern/$subst/g.\n"; }
    my $new_pathname = $pathname;
    $new_pathname =~ s/$pattern/$subst/g;
    if ($new_pathname =~ /^\.\//) {
        $new_pathname =~ s/^\.\///;
    }
    print "$pathname -> $new_pathname\n";
    print "Wyedytuj $0 i odkomentuj rename :)\n";
    #rename $pathname, $new_pathname;
  }

}
