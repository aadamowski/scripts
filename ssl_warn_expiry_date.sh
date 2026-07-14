#!/usr/bin/env bash
# Author: Aleksander Adamowski
set -euo pipefail
host="$1"
printf '\n' | openssl s_client -connect "$host" 2>/dev/null | \
 sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' | \
 openssl x509 -noout -enddate | perl -e "
use POSIX qw(strftime);
use Date::Parse;
\$_ = <>;
/^notAfter=(.*)/;
\$expirytime=Date::Parse::str2time(\$1);
\$timediff = \$expirytime - time;
if (\$timediff < 3600*24*31) {
	print 'Only '.(\$timediff /3600/24).' days left until SSL certificate expiry on $host';
	print \"\n\";
}
";
