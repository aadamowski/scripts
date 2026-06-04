#!/bin/sh
convert -geometry 25% -density 288 +dither $1 png:$1%02d.png
