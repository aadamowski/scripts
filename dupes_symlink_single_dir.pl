#!/usr/bin/perl
# Aleksander Adamowski (s1869)
# czw paź 28 22:11:16 CEST 2004
# Znajduje duplikaty obrazkow i zastepuje je symlinkami do oryginalow

use strict;
use Getopt::Std;
use Fcntl ':mode';
use File::Basename;
use Data::Dumper;
use Digest::MD5;
use File::Spec;

my $debug_recurse = 0;
my $debug = 0;
my %file_sizes;

our($opt_h, $opt_n, $opt_s);
getopts('hns');

if ($opt_h) {
  print STDERR "Uzycie: $0 [-s -n -h]\n";
  print STDERR " -s : dokonaj substytucji duplikatow symlinkami do oryginalow\n";
  print STDERR " -n : nie dokonuj substytucji domyslnie\n";
  print STDERR " -h : ten tekst pomocy\n";
  exit(1);
}


descend('.', \&process);

sub descend {
  my $dirname = shift;
  my $func = shift;
  opendir DH, $dirname;
  my @descend_list;
  my @process_list;
  my $entry;
  my $pathname;
  while ($entry = readdir(DH)) {
    if ($entry !~ '^\.$' && $entry !~ '^\.\.$') {
      $pathname = $dirname.'/'.$entry;
      if ($debug_recurse) { print "wpis: $pathname\n"; }
      my $mode = (stat($pathname))[2];

      if (S_ISDIR($mode)) {
        if ($debug_recurse) { print "$pathname to katalog.\n"; }
        push @descend_list, $pathname;
      } elsif (-f $pathname && (! readlink($pathname))) {
        push @process_list, $pathname;
        if ($debug_recurse) { print "$pathname to plik.\n"; }
      }
    }
  }
  closedir DH;
  foreach $pathname (@process_list) {
    &$func($pathname);
  }
  foreach my $subdir (@descend_list) {
    descend($subdir, $func);
  }
}

sub file_checksum {
  my $pathname = shift;
  open(FILE, $pathname) or die "Can't open '$pathname': $!";
  binmode(FILE);
  my $md5_checksum = Digest::MD5->new->addfile(*FILE)->hexdigest;
  close(FILE);
  return $md5_checksum;
}

sub process {
  my $pathname = shift;
  my $pathname = File::Spec->rel2abs($pathname);
  my $size = (stat($pathname))[7];
  my $orig_pathname;

  if (defined($file_sizes{$size})) {
    # zaladowanie sumy kontrolnej oryginalu na zadanie:
    if (scalar(keys(%{$file_sizes{$size}})) <= 1) {
      # sumy kontrolnej oryginalu nie ma
      $orig_pathname = $file_sizes{$size}{'_orig_'};
      my $orig_file_checksum = file_checksum($orig_pathname);
      $file_sizes{$size}{$orig_file_checksum} = $orig_pathname;
    }
    my $file_checksum = file_checksum($pathname);
    if (defined($file_sizes{$size}{$file_checksum})) {
      # rozpatrywany plik to duplikat wczesniej znalezionego oryginalu
      $orig_pathname = $file_sizes{$size}{$file_checksum};

      print "$pathname is a dupe of $orig_pathname.";

      # Usuniecie duplikatu i zastapienie dowiazaniem do oryginalu:
      if ($opt_s && (! $opt_n)) {
        print " Substituting with a symlink to original.\n";
        unlink $pathname;
        symlink $orig_pathname, $pathname;
      } else {
        print "\n";
      }
    } else {
      $file_sizes{$size}{$file_checksum} = $pathname;
    }
  } else {
    $file_sizes{$size} = { '_orig_' => $pathname };
  }
}
