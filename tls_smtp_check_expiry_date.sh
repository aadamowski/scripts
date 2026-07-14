#!/usr/bin/env bash
#
# Description: Checks the expiry date of the TLS certificate for an SMTP server.
# Dependencies: bash, openssl, sed, perl
# Usage: ./tls_smtp_check_expiry_date.sh <hostname>
# Author: Aleksander Adamowski
#

set -euo pipefail

printf '\n' | openssl s_client -starttls smtp -connect "$1:25" 2>/dev/null | \
 sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' | \
 openssl x509 -noout -enddate | perl -e '
use POSIX qw(strftime);
use Date::Parse;
$_ = <>;
/^notAfter=(.*)/;
print strftime("%F", Date::Parse::strptime($1));
print "\n";
';
