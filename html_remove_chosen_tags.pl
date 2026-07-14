#!/usr/bin/env perl
#
# Description: Removes specified HTML tags (script, iframe) from an HTML document.
# Dependencies: perl, HTML::Parser
# Usage: perl html_remove_chosen_tags.pl <file.html>
# Author: Aleksander Adamowski
#
# Note: This script uses HTML::Parser to identify and skip specific tags.

use strict;
use warnings;
use utf8;
use HTML::Parser;

sub handler {
    my ($text, $tagname) = @_;
    
    if (defined $tagname) {
        # Skip script and iframe tags
        return if $tagname eq 'script' || $tagname eq 'iframe';
    }
    
    print $text if defined $text;
}

my $filename = shift or die "Usage: $0 <file.html>\n";

my $parser = HTML::Parser->new(api_version => 3);
$parser->handler(default => \&handler, 'text, tagname');

$parser->parse_file($filename) or die "Parsing error: $!";

print "\n";


