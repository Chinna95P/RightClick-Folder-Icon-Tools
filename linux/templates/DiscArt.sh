#!/bin/bash
# Template-Version=v1.0

#                Template Config
#========================================================
#--------- Label --------------------------
export display_label="yes"
export display_logo="yes"
#========================================================

#                Images Source
#========================================================
discArt_main="$APP_DIR/images/DiscArt-Main.png"
discArt_border="$APP_DIR/images/DiscArt-Border.png"
discArt_transparent="$APP_DIR/images/DiscArt-Transparent.png"
discArt_label="$APP_DIR/images/DiscArt-Label.png"
discArt_logo="$APP_DIR/images/DiscArt-Logo.png"
canvas="$APP_DIR/images/- canvas.png"
#========================================================

#                Code
#========================================================
shopt -s nocasematch
if [[ "$display_label" != "yes" ]]; then discArt_label="$canvas"; fi
if [[ "$display_logo" != "yes" ]]; then discArt_logo="$canvas"; fi

if [[ "$referrer" == "DVDcase" ]]; then
    inDiscArt="$gen_disc"
    outDiscArt="DiscArt($FI_ID).png"
    DiscArt="DiscArt($FI_ID).png"
    deltemp="rm -f \"DiscArt($FI_ID).png\""
else
    outDiscArt="$OutputFile"
    inDiscArt="$inputfile"
fi
shopt -u nocasematch

"$IM_CMD" \
  \( "$canvas" -scale 512x512\! -background none -extent 512x512 \) -compose Over \
  \( "$inDiscArt" -scale 485x485\! -gravity center "$discArt_main" \) -compose over -composite \
  \( "$discArt_transparent" -scale 512x512\! \) -compose over -composite \
  \( "$discArt_label" -scale 512x512\! \) -compose over -composite \
  \( "$discArt_logo" -scale 512x512\! \) -compose over -composite \
  \( "$inDiscArt" -scale 900x900\! -blur 0x30 -brightness-contrast 0x30 "$discArt_border" \) -compose over -composite \
  -define icon:auto-resize="$TemplateIconSize" \
  "$outDiscArt"

if [[ -n "$deltemp" ]]; then
    eval "$deltemp"
    deltemp=""
fi
