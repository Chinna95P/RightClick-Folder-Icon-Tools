#!/bin/bash

# Template: DVDCase Bluray
# DVD Bluray case frame around poster with glowing text.

TARGET_DIR=$(dirname "$inputfile")

if [ -f "$APP_DIR/resources/extract-nfo.sh" ]; then
    source "$APP_DIR/resources/extract-nfo.sh" "$TARGET_DIR"
fi

if [ -z "$rating" ]; then rating="0.0"; fi
if [ -z "$genre" ]; then genre="Unknown"; fi

# Path to the bundled font, fallback to standard Arial
FONT_PATH="$APP_DIR/resources/ANGIE-BOLD.TTF"
if [ ! -f "$FONT_PATH" ]; then
    FONT_PATH="Arial-Bold"
fi

"$IM_CMD" \
    \( "$APP_DIR/images/- canvas.png" -scale 512x512\! -background none -extent 512x512 \) -compose Over \
    \( "$inputfile" -scale 340x438\! -background none -gravity Northwest -geometry +78+48 \) -compose over -composite \
    \( "$APP_DIR/images/dvdcase-bluray.png" -resize 512x512\! \) -compose over -composite \
    \( +clone -background BLACK -shadow 0x2+2+2.5 \) +swap -background none -layers merge -extent 512x512 \
    \( "$APP_DIR/images/star.png" -scale 88x88\! -gravity Northwest -geometry +356+420 \( +clone -background BLACK -shadow 40x1.2+1.8+3 \) +swap -background none -layers merge -extent 512x512 \) -compose over -composite \
    -font "$FONT_PATH" -fill "rgba(0,0,0,0.9)" -density 400 -pointsize 6 -gravity Northwest -geometry +369+446 label:"$rating" \
    \( +clone -background ORANGE -shadow 30x1.2+2+2 \) +swap -background none -layers merge \
    \( +clone -background YELLOW -shadow 30x1.2-2-2 \) +swap -background none -layers merge \
    \( +clone -background ORANGE -shadow 30x1.2-2+2 \) +swap -background none -layers merge \
    \( +clone -background ORANGE -shadow 30x1.2+2-2 \) +swap -background none -layers merge -compose over -composite \
    -font "$FONT_PATH" -fill BLACK -density 400 -pointsize 5 -gravity SouthEast -geometry +140-9 label:"$genre" \
    \( +clone -background ORANGE -shadow 70x1.2+2.6+2.6 \) +swap -background none -layers merge \
    \( +clone -background YELLOW -shadow 70x1.2-2.6-2.6 \) +swap -background none -layers merge \
    \( +clone -background ORANGE -shadow 70x1.2-2.6+2.6 \) +swap -background none -layers merge \
    \( +clone -background ORANGE -shadow 70x1.2+2.6-2.6 \) +swap -background none -layers merge \
    \( +clone -background BLACK  -shadow 0x0.2+4+5 \) +swap -background none -layers merge -compose over -composite \
    -define icon:auto-resize="$TemplateIconSize" "$outputfile"
