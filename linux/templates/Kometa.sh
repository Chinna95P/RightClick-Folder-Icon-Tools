#!/bin/bash

# Template: Kometa
# Kometa-style media display (poster + rating/genre pill badges)

# Read NFO if available (the script expects to run in the target folder context)
# We assume the caller runs us from the target directory, or we derive it from inputfile
TARGET_DIR=$(dirname "$inputfile")

if [ -f "$APP_DIR/resources/extract-nfo.sh" ]; then
    source "$APP_DIR/resources/extract-nfo.sh" "$TARGET_DIR"
fi

# Fallback values if NFO didn't provide them
if [ -z "$rating" ]; then rating="0.0"; fi
if [ -z "$genre" ]; then genre="Unknown"; fi

"$IM_CMD" \
    \( "$APP_DIR/images/- canvas.png" -scale 512x512\! -background none -extent 512x512 \) -compose Over \
    \( "$inputfile" -scale 343x492\! -background none -gravity center -geometry +0-2 "$APP_DIR/images/Kometa-shape.png" \) -compose Over -composite \
    \( "$APP_DIR/images/Kometa-shadow.png" -scale 512x512\! \) -compose over -composite \
    \( "$APP_DIR/images/Kometa-rating.png" -scale 84x30\! -gravity Southwest -geometry +100+19 \) -compose over -composite \
    -font "Arial-Bold" -fill "rgba(255,255,255,0.9)" -density 400 -pointsize 3.6 -kerning 0 \
    -gravity Southwest -geometry +151+21 label:"$rating" -compose over -composite \
    \( "$APP_DIR/images/Kometa-genre.png" -scale 224x30\! -gravity Southwest -geometry +190+19 \) -compose over -composite \
    -font "Arial-Bold" -fill "rgba(255,255,255,0.9)" -density 400 -pointsize 3.6 -kerning 0 \
    -gravity Southwest -geometry +194+21 label:"$genre" -compose over -composite \
    -define icon:auto-resize="$TemplateIconSize" "$outputfile"
