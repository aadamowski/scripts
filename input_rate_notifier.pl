#!/usr/bin/perl -w
# by Aleksander Adamowski
# Wed Nov 23 23:26:12 CET 2005
# Skrypt wykrywa przekroczenie pewnej ilosci wierszy na ilosc sekund na STDIN
# i uruchamia dane polecenie powiadamiajace o przekroczeniu.

use strict;

if (scalar(@ARGV) < 3) {
  die "Uzycie: $0 ilosc_wierszy ilosc_sekund polecenie_powiadamiajace\n";
}

my $rowcount = $ARGV[0];
my $seconds = $ARGV[1];
my $notificator = $ARGV[2];
my @queue = ();

# Kiedy ostatnio bylo powiadomienie (moze byc nie czesciej, niz ilosc_sekund aby uniknac spamowania):
my $lastnotification = 0;

my $time;
my $tailtime;
my $queuetime;

while (<STDIN>) {
  $time = time;
  unshift @queue, $time;
  # Jesli kolejka jest pelna, zaczynamy zdejmowac wpisy z jej konca:
  if (scalar(@queue) > $rowcount) {
    pop @queue;
    # Czas na koncu kolejki:
    $tailtime = $queue[$#queue];
    # Jesli koniec kolejki jest malo oddalony w czasie (ponizej $seconds) od poczatku, to przeplywnosc jest przekroczona:
    $queuetime = (time - $tailtime);
    if ($queuetime < $seconds && (time - $lastnotification) > $seconds) {
      # Powiadamiamy:
      #print "Rate EXCEEDED! $rowcount rows / $queuetime seconds\n";
      system $notificator or die $?;
      $lastnotification = time;
    }
  }
}

