#!/bin/sh
echo "" | openssl s_client -connect "$@" 2>/dev/null | \
 sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' | \
 openssl x509 -noout -enddate | perl -e '
use POSIX qw(strftime);
use Date::Parse;
$_ = <>;
/^notAfter=(.*)/;
print strftime("%F", Date::Parse::strptime($1));
print "\n";
';
