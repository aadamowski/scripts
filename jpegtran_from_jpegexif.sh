#!/bin/sh
for jpg in "$@"; do
    #randname="$(dd if=/dev/urandom bs=256 count=1 2>/dev/null | md5sum -b | cut -b 1-32).tmp"
    #touch -r "$jpg" -F 1 $randname
    echo $orient "$jpg";
    #jpegtran -copy all -rotate 90 "$jpg" > "$jpg.tmp" && mv -f "$jpg.tmp" "$jpg" &&  jpegexiforient -1 "$jpg";
    jhead -autorot -ft "$jpg"
    #touch -r $randname "$jpg"
    #rm $randname
done;
