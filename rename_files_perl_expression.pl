#!/usr/bin/env perl
#
# Description: Recursively searches subdirectories and renames files/directories
#              based on a PCRE pattern and substitution.
# Dependencies: perl
# Usage: perl rename_files_perl_expression.pl '<pattern>' '<substitution>'
# Author: Aleksander Adamowski
#
# Note: The renaming part is commented out by default for safety.

use strict;
use warnings;
use File::Spec;

my $debug = 1;
my $pattern;
my $subst;

if ($#ARGV >= 1) {
    $pattern = qr/$ARGV[0]/;
    $subst = $ARGV[1];
} else {
    die "Przeszukuje rekursywnie biezacy podkatalog i przemianowuje zawartosc.\n" .
        "Uzycie:\n$0 wzorzec_PCRE substytucja_PCRE \n" .
        "Przyklad:\n$0 '\\.doc' '.ole'\n";
}

my $dirname = '.';
if (-d $dirname) {
    if ($debug) { print "$dirname to katalog.\n"; }
    descend($dirname);
}

sub descend {
    my ($dir) = @_;
    opendir(my $dh, $dir) or die "can't opendir $dir: $!";
    
    my @descend_list;
    my @process_list;
    my $entry;
    my $pathname;
    
    while ($entry = readdir($dh)) {
        next if $entry eq '.' || $entry eq '..';
        $pathname = File::Spec->catfile($dir, $entry);
        
        if (-d $pathname) {
            push @descend_list, $pathname;
        } elsif (-f $pathname) {
            push @process_list, $pathname;
        }
    }
    closedir $dh;
    
    foreach my $p (@process_list) {
        process($p);
    }
    foreach my $subdir (@descend_list) {
        descend($subdir);
        process($subdir);
    }
}

sub process {
    my ($pathname) = @_;
    if ($debug) { print "przetwarzanie $pathname\n"; }
    
    if ($pathname =~ /$pattern/) {
        if ($debug) { print "$pathname pasuje do wzorca $pattern, dokonuje substytucji s/$pattern/$subst/g.\n"; }
        my $new_pathname = $pathname;
        $new_pathname =~ s/$pattern/$subst/g;
        
        # Remove leading ./ if present
        $new_pathname =~ s/^\.\///;
        
        print "$pathname -> $new_pathname\n";
        print "Wyedytuj $0 i odkomentuj rename :)\n";
        # rename $pathname, $new_pathname;
    }
}
