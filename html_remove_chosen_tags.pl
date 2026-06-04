#!/usr/bin/perl -w
# Aleksander Adamowski (s1869)
# nie lis 21 12:24:48 CET 2004
# Usuwa wybrane tagi z dokumentu HTML


use strict;
use HTML::Parser ();
#use encoding "utf-8";
#use open ':utf8';
#use open OUT => ':utf8';
#use open IN => ':utf8';
#use open ':std'; 
use utf8;

sub handler
{
  my $text = shift;
  my $tagname = shift;
  if (defined($tagname)) {
    if ( $tagname =~ 'script' || $tagname =~ 'iframe' )  { return; }
  } 
  print $text."\n";
}


my $p = HTML::Parser->new(api_version => 3);
$p->handler( default => \&handler, 'text, tagname');
$p->parse_file(shift || die) || die $!;
print "\n";

