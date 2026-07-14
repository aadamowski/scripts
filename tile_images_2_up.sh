#!/usr/bin/env bash
set -euo pipefail
#
# Description: Takes pairs of images from the current directory and creates 1x2 tiled images.
# Dependencies: bash, ImageMagick (montage), find
# Usage: ./tile_images_2_up.sh
# Author: Aleksander Adamowski
#
# Note: Creates a 'tiled' directory for output.

mkdir -p tiled

idx=0
declare -a tiledarr

# Find files in current directory (depth 1)
for image in $(find ./ -mindepth 1 -maxdepth 1 -type f); do
    arridx=$((idx % 2))
    
    # If we have a full pair (arridx is 0, meaning we just completed a pair of 2)
    # Actually, the original logic was:
    # if [[ -n "${tiledarr+x}" && $arridx -eq 0 ]]; then print=1; ...
    # This logic is a bit confusing. Let's implement a cleaner version.
    
    if [[ $arridx -eq 0 && $idx -gt 0 ]]; then
        # We have a pair in tiledarr[0] and tiledarr[1]
        montage -geometry +4+4 -tile 1x2 "${tiledarr[0]}" "${tiledarr[1]}" "tiled/$((idx/2)).png"
        idx=$((idx + 1))
    else
        tiledarr[$arridx]="$image"
        idx=$((idx + 1))
    fi
done

# If there's one remaining image in the array, we can't tile it 1x2

