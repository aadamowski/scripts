#!/usr/bin/env perl
#
# Description: Finds duplicate files by MD5 checksum and optionally replaces them with symlinks to the originals.
# Dependencies: perl, Digest::MD5, File::Basename, File::Spec
# Usage: perl dupes_symlink_single_dir.pl [-s] [-n] [-h]
# Author: Aleksander Adamowski
#
# Options:
# -s: Perform substitution of duplicates with symlinks to originals.
# -n: Do not perform substitution (just report duplicates).
# -h: Display help text.

use strict;
use warnings;
use Getopt::Std;
use File::Basename;
use File::Spec;
use Digest::MD5;

my %opts;
getopts('hns', \%opts);

if ($opts{h}) {
    print STDERR "Usage: $0 [-s] [-n] [-h]\n";
    print STDERR " -s : Perform substitution of duplicates with symlinks to originals.\n";
    print STDERR " -n : Do not perform substitution (just report duplicates).\n";
    print STDERR " -h : Display help text.\n";
    exit(0);
}

my %file_sizes;

descend('.', \&process);

sub descend {
    my ($dirname, $func) = @_;
    opendir(my $dh, $dirname) or die "can't opendir $dirname: $!";
    
    my @entries;
    while (my $entry = readdir($dh)) {
        next if $entry eq '.' || $entry eq '..';
        push @entries, $entry;
    }
    closedir $dh;
    
    foreach my $entry (@entries) {
        my $pathname = File::Spec->catfile($dirname, $entry);
        
        # Check if it is a directory or a file (and not a symlink itself, to avoid loops/double processing)
        if (-d $pathname && ! -l $pathname) {
            descend($pathname, $func);
        } elsif (-f $pathname && ! -l $pathname) {
            $func->($pathname);
        }
    }
}

sub file_checksum {
    my ($pathname) = @_;
    open(my $fh, '<', $pathname) or die "Can't open '$pathname': $!";
    binmode($fh);
    my $md5_checksum = Digest::MD5->new->addfile($fh)->hexdigest;
    close($fh);
    return $md5_checksum;
}

sub process {
    my ($pathname) = @_;
    $pathname = File::Spec->rel2abs($pathname);
    my @stat = stat($pathname);
    return unless @stat;
    my $size = $stat[7];

    my $current_checksum = file_checksum($pathname);

    if (exists $file_sizes{$size}) {
        if (exists $file_sizes{$size}{$current_checksum}) {
            # It's a duplicate
            my $dup_of = $file_sizes{$size}{$current_checksum};
            print "$pathname is a dupe of $dup_of.";

            if ($opts{s} && !$opts{n}) {
                print " Substituting with a symlink to original.\n";
                unlink $pathname or warn "Could not unlink $pathname: $!";
                symlink $dup_of, $pathname or warn "Could not symlink $pathname to $dup_of: $!";
            } else {
                print "\n";
            }
        } else {
            # New unique file for this size
            $file_sizes{$size}{$current_checksum} = $pathname;
        }
    } else {
        # First time seeing this size
        $file_sizes{$size} = {
            '_orig_' => $pathname,
            $current_checksum => $pathname,
        };
    }
}
