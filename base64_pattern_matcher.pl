#!/usr/bin/perl -w
use MIME::Base64;

$| = 1;

while (<>) {
# Usuwamy znak konca wiersza:
  chomp;
  $shift0 = encode_base64($_);
  if (length($shift0) < 3) {
    print STDERR "Blad! za krotki wzorzec. Tylko wzorce liczace co najmniej 4 znaki maja sens teoretyczny, a co najmniej 6 znakow sens praktyczny.\n\n"
  } else {

    print "\n";

    $shift0 =~ s/=+$//;
    $shift0 = substr($shift0, 0, length($shift0) - 2);
    print $shift0."\n";

    my $shift1 = encode_base64(" ".$_);
# kiedy dodajemy jeden znak na pocz., ma on wplyw na 2 pierwsze znaki 
# w wyniku b64 wiec je ucinamy:
    $shift1 = substr($shift1, 2);
# znaki '=' z konca tez ucinamy:
    $shift1 =~ s/=+$//;
# ostatnie 2 znaki base64 moga zalezec od znakow dodawanych na koncu stringu
# wiec tez je ucinamy
    $shift1 = substr($shift1, 0, length($shift1) - 2);
    print $shift1."\n";

    my $shift2 = encode_base64("  ".$_);
# kiedy dodajemy 2 znaki na pocz., maja one wplyw na 3 pierwsze znaki 
# w wyniku b64 wiec je ucinamy:
    $shift2 = substr($shift2, 3);
# znaki '=' z konca tez ucinamy:
    $shift2 =~ s/=+$//;
# ostatnie 2 znaki base64 moga zalezec od znakow dodawanych na koncu stringu
# wiec tez je ucinamy
    $shift2 = substr($shift2, 0, length($shift2) - 2);
    print $shift2."\n";
    print "\n";

  }
}
