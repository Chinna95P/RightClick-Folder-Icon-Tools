#!/bin/bash
#      Template Info
#===================================
#` Output image will be the same as source image, without frame or anything
#` but with added shadow and image posisition will be in the center.
#` Convert and edit using ImageMagick.
#` -------------------------------------------------------------------

#      Template Config
#===================================
image_position="CENTER"

# |----------------------------------|
# |          image-position          |
# | Northwest   North    Northeast   |
# | West        Center   East        |
# | SouthWest   South    SouthEast   |
# |----------------------------------|

shadow_color="BLACK"
shadow_opacity="60"
shadow_blur="5"
shadow_X_position="+5"
shadow_Y_position="+6.5"


#      Template Command
#===================================
"$IM_CMD" "$inputfile" -resize 490x490 \( +clone -background "$shadow_color" -shadow "${shadow_opacity}x${shadow_blur}${shadow_X_position}${shadow_Y_position}" \) +swap -background none -layers merge -gravity "$image_position" -extent 512x512 -define icon:auto-resize="$TemplateIconSize" "$OutputFile"
