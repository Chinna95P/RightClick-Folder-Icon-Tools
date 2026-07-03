#!/bin/bash

# Template: (none)
# Output image will be identical to the source image, without a frame or shadow.
# Additionally, the image will be positioned at the center of a 1:1 image ratio.

if [[ "$inputfile" == *.ico ]]; then
    cp "$inputfile" "$outputfile"
    exit 0
fi

"$IM_CMD" "$inputfile" -resize 512x512 -background none -gravity CENTER -extent 512x512 -define icon:auto-resize="$TemplateIconSize" "$outputfile"
