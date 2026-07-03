#!/bin/bash

# Template: (Shadow Only)
# Output image will be the same as source image, without frame or anything
# but with added shadow and image position will be in the center.

image_position="CENTER"
shadow_color="BLACK"
shadow_opacity="60"
shadow_blur="5"
shadow_x_position="+5"
shadow_y_position="+6.5"

"$IM_CMD" "$inputfile" -resize 490x490 \
    \( +clone -background "$shadow_color" -shadow "${shadow_opacity}x${shadow_blur}${shadow_x_position}${shadow_y_position}" \) \
    +swap -background none -layers merge \
    -gravity "$image_position" -extent 512x512 \
    -define icon:auto-resize="$TemplateIconSize" "$outputfile"
