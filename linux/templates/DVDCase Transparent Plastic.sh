#!/bin/bash
# Template-Version=v1.2

#                Template Config
#========================================================
use_GlobalConfig="Yes"

display_movieinfo="yes"
show_Rating="yes"
preferred_rating="imdb"
show_Genre="yes"
genre_characters_limit="26"
#========================================================

#                Images Source
#========================================================
frame_image="$APP_DIR/images/dvdcase-plastic.png"
frame_image_mask="$APP_DIR/images/dvdcase-plastic-mask.png"
star_image="$APP_DIR/images/star.png"
canvas="$APP_DIR/images/- canvas.png"
#========================================================

shopt -s nocasematch

# LAYER-BASE
if [[ "$use_GlobalConfig" == "Yes" ]] && [[ -f "$RCFI_templates_ini" ]]; then
    while IFS='=' read -r key value; do
        if [[ -n "$value" ]] && [[ "$value" != " " ]]; then
            key=$(echo "$key" | xargs)
            value=$(echo "$value" | tr -d '\r' | xargs)
            export "$key=$value"
        fi
    done < "$RCFI_templates_ini"
fi

LAYER_BACKGROUND=( \( "$canvas" -scale 512x512\! -background none -extent 512x512 \) -compose Over )

LAYER_POSTER_IMAGE=( \( "$inputfile" -scale 336x474\! -gravity Northwest -geometry +108+14 "$frame_image_mask" \) -compose over -composite )

LAYER_FRAME_IMAGE=( \( "$frame_image" -resize 512x512\! \) -compose Over -composite )

LAYER_ICON_SIZE=( -define icon:auto-resize="$TemplateIconSize" )

# LAYER-RATING
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
            LAYER_STAR_IMAGE=( \( "$star_image" -scale 88x88\! -gravity Northwest -geometry +370+405 \( +clone -background BLACK -shadow 40x1.2+1.8+3 \) +swap -background none -layers merge -extent 512x512 \) -compose Over -composite )
            
            if [[ -n "$rating" ]]; then
                LAYER_RATING=( \( -font "$APP_DIR/resources/ANGIE-BOLD.TTF" -fill "rgba(0,0,0,0.9)" -density 400 -pointsize 6 label:"$rating" -gravity Northwest -geometry +383+432 \( +clone -background ORANGE -shadow 30x1.2+2+2 \) +swap -background none -layers merge \( +clone -background YELLOW -shadow 30x1.2-2-2 \) +swap -background none -layers merge \( +clone -background ORANGE -shadow 30x1.2-2+2 \) +swap -background none -layers merge \( +clone -background ORANGE -shadow 30x1.2+2-2 \) +swap -background none -layers merge \) -compose Over -composite )
            fi
        fi
    fi
fi

# LAYER-GENRE
LAYER_GENRE=()
if [[ "$display_movieinfo" == "yes" ]] && [[ "$show_Genre" == "yes" ]] && [[ -n "$genre" ]]; then
    LAYER_GENRE=( \( -font "$APP_DIR/resources/ANGIE-BOLD.TTF" -fill BLACK -density 400 -pointsize 5 -gravity SouthEast -geometry +123+15 label:"$genre" \( +clone -background ORANGE -shadow 70x1.2+2.7+2.7 \) +swap -background none -layers merge \( +clone -background YELLOW -shadow 70x1.2-2.7-2.7 \) +swap -background none -layers merge \( +clone -background ORANGE -shadow 70x1.2-2.7+2.7 \) +swap -background none -layers merge \( +clone -background ORANGE -shadow 70x1.2+2.7-2.7 \) +swap -background none -layers merge \( +clone -background BLACK -shadow 0x0.2+4+5 \) +swap -background none -layers merge \) -composite )
fi

shopt -u nocasematch

"$IM_CMD" \
  "${LAYER_BACKGROUND[@]}" \
  "${LAYER_POSTER_IMAGE[@]}" \
  "${LAYER_FRAME_IMAGE[@]}" \
  "${LAYER_STAR_IMAGE[@]}" \
  "${LAYER_RATING[@]}" \
  "${LAYER_GENRE[@]}" \
  "${LAYER_ICON_SIZE[@]}" \
  "$OutputFile"
