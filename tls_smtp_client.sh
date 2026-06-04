if [ $# -eq 1 ]; then
  openssl s_client -starttls smtp -connect $@
else
  echo "Uzycie: $0 host:port"
  echo "n.p.:"
  echo "$0 nmail.altkom.pl:25"
fi

