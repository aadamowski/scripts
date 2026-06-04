#!/bin/sh

histfile="$1"
sqlite3 "${histfile}" "select datetime(visits.visit_time/1000000-11644473600, 'unixepoch','localtime'),urls.url,urls.title from urls INNER JOIN visits ON urls.id = visits.url ORDER BY visits.visit_time DESC;"

