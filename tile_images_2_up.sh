#!/bin/bash

idx=0;
for image in $(find ./  -mindepth 1 -maxdepth 1 -type f ); do
  arridx=$((idx % 2));
  print=0;
  if [ -n "${tiledarr+x}" -a $arridx -eq 0 ]; then
    print=1;
  else
    print=0;
  fi;
  tiledarr[arridx]=$image;
  idx=$((idx+1));
  if [ $print -eq 1  ]; then
    montage -geometry +4+4 -tile 1x2 ${tiledarr[*]} tiled/$idx.png;
  fi;
done;
