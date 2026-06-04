#!/bin/sh
gs -sDEVICE=png16m  -sOutputFile=${1}-str%d.png -r300x300 -q -dBATCH -dNOPAUSE -dTextAlphaBits=4 $1
