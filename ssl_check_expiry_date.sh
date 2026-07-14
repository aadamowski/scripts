#!/usr/bin/env bash
#
# Description: Checks the expiry date of the TLS certificate for a given host.
# Dependencies: bash, openssl, sed, perl
# Usage: ./ssl_check_expiry_date.sh <hostname>[:port]
# Author: Aleksander Adamowski
#

set -euo pipefail

printf '\n' | openssl s_client -connect "$@" 2>/dev/null | \
 sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' | \
 openssl x509 -noout -enddate | perl -e '
use POSIX qw(strftime);
use Date::Parse;
$_ = <>;
/^notAfter=(.*)/;
print strftime("%F", Date::Parse::strptime($1));
print "\n";
';
