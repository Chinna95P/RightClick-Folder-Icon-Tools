#!/bin/bash
# Template-Version=v1.2

#                Template Config
#========================================================
use_GlobalConfig="yes"

display_movieinfo="yes"
show_Rating="yes"
preferred_rating="imdb"
show_Genre="yes"
genre_characters_limit="24"
#========================================================

#                Images Source
#========================================================
frame_image="$APP_DIR/images/dvdcase-bluray.png"
star_image="$APP_DIR/images/star.png"
canvas="$APP_DIR/images/- canvas.png"
#========================================================

shopt -s nocasematch

if [[ "$use_GlobalConfig" == "yes" ]] && [[ -f "$RCFI_templates_ini" ]]; then
    while IFS='=' read -r key value; do
        if [[ -n "$value" ]] && [[ "$value" != " " ]]; then
            key=$(echo "$key" | xargs | sed 's/-/_/g')
            value=$(echo "$value" | tr -d '\r' | xargs)
            export "$key=$value"
        fi
    done < "$RCFI_templates_ini"
fi

LAYER_BACKGROUND=( \( "$canvas" -scale 512x512\! -background none -extent 512x512 \) -compose Over )

LAYER_POSTER_IMAGE=( \( "$inputfile" -scale 340x438\! -background none -gravity Northwest -geometry +78+48 \) -compose Over -composite )

LAYER_FRAME_IMAGE=( \( "$frame_image" -resize 512x512\! \) -compose Over -composite )

LAYER_THE_SHADOW=( \( +clone -background BLACK -shadow 0x2+2+2.5 \) +swap -background none -layers merge -extent 512x512 )

LAYER_ICON_SIZE=( -define icon:auto-resize="$TemplateIconSize" )

LAYER_STAR_IMAGE=()
LAYER_RATING=()
if [[ "$display_movieinfo" == "yes" ]]; then
    has_nfo=false
    for f in *.nfo; do
        if [[ -f "$f" ]]; then
            has_nfo=true
            break
        fi
    done
    if $has_nfo; then
        source "$APP_DIR/linux/resources/extract-nfo.sh"
        if [[ "$show_Rating" == "yes" ]]; then
            LAYER_STAR_IMAGE=( \( "$star_image" -scale 88x88\! -gravity Northwest -geometry +356+420 \( +clone -background BLACK -shadow 40x1.2+1.8+3 \) +swap -background none -layers merge -extent 512x512 \) -compose Over -composite )
            if [[ -n "$rating" ]]; then
                LAYER_RATING=( \( -font "$APP_DIR/resources/ANGIE-BOLD.TTF" -fill "rgba(0,0,0,0.9)" -density 400 -pointsize 6 label:"$rating" -gravity Northwest -geometry +369+446 \( +clone -background ORANGE -shadow 30x1.2+2+2 \) +swap -background none -layers merge \( +clone -background YELLOW -shadow 30x1.2-2-2 \) +swap -background none -layers merge \( +clone -background ORANGE -shadow 30x1.2-2+2 \) +swap -background none -layers merge \( +clone -background ORANGE -shadow 30x1.2+2-2 \) +swap -background none -layers merge \) -compose Over -composite )
            fi
        fi
    fi
fi

LAYER_GENRE=()
if [[ "$display_movieinfo" == "yes" ]] && [[ "$show_Genre" == "yes" ]] && [[ -n "$genre" ]]; then
    LAYER_GENRE=( \( -font "$APP_DIR/resources/ANGIE-BOLD.TTF" -fill BLACK -density 400 -pointsize 5 -gravity SouthEast -geometry +140-9 label:"$genre" \( +clone -background ORANGE -shadow 70x1.2+2.7+2.7 \) +swap -background none -layers merge \( +clone -background YELLOW -shadow 70x1.2-2.7-2.7 \) +swap -background none -layers merge \( +clone -background ORANGE -shadow 70x1.2-2.7+2.7 \) +swap -background none -layers merge \( +clone -background ORANGE -shadow 70x1.2+2.7-2.7 \) +swap -background none -layers merge \( +clone -background BLACK -shadow 0x0.2+4+5 \) +swap -background none -layers merge \) -composite )
fi

shopt -u nocasematch

"$IM_CMD" \
  "${LAYER_BACKGROUND[@]}" \
  "${LAYER_POSTER_IMAGE[@]}" \
  "${LAYER_FRAME_IMAGE[@]}" \
  "${LAYER_THE_SHADOW[@]}" \
  "${LAYER_STAR_IMAGE[@]}" \
  "${LAYER_RATING[@]}" \
  "${LAYER_GENRE[@]}" \
  "${LAYER_ICON_SIZE[@]}" \
  "$OutputFile"
