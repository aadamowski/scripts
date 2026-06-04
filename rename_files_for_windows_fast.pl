#!/bin/bash

(find ./ -depth -type d; find ./ -depth -type f;) | perl -e "
use File::Basename;
my \$illegal_chars = qr/[\\ \\|\\&\\?\\!\\*\\[\\]\\(\\)\\,\\=\\:\\@\\'\\\"]+/;
while (<>) {
  if (/\$illegal_chars/) {
    chomp;
    my \$old = \$_;
    my \$basename = basename(\$old);
    my \$dirname = dirname(\$old);
    \$basename =~ s/\$illegal_chars/_/g;
    \$basename =~ s/_{2,}/_/g;
    my \$new = \"\$dirname/\$basename\";
    print \"\$old ->\n-> \$new\n\";
    if ( -e \$new ) {
      print STDERR \"already exists: \$new\n\";
    } else {
    rename \$old, \$new;
    }
  }
}
"
