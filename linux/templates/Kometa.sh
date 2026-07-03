#!/bin/bash

#      Template Info
#===================================
#` kometa style media display.
#` -------------------------------------------------------------------

#                Template Config
#========================================================
use_GlobalConfig="yes"

#--------- Movie Info ---------------------
display_MovieInfo="yes"
show_Rating="yes"
preferred_rating="imdb"
show_Genre="yes"
genre_characters_limit="21"

#--------- Poster -------------------------
poster_size="343x492"
poster_gravity="center"
poster_X_position="-2"
poster_Y_position="+0"

#--------- Rating -------------------------
rating_font_style="Arial-Bold"
rating_font_color="rgba(255,255,255,0.9)"
rating_font_size="3.6"
rating_gravity="Southwest"
rating_X_position="+21"
rating_Y_position="+151"

BG_rating_size="84x30"
BG_rating_gravity="Southwest"
BG_rating_X_position="+19"
BG_rating_Y_position="+100"

#--------- Genre --------------------------
genre_font_style="Arial-Bold"
genre_font_color="rgba(255,255,255,0.9)"
genre_font_size="3.6"
genre_gravity="Southwest"
genre_X_position="+21"
genre_Y_position="+194"

BG_genre_size="224x30"
BG_genre_gravity="Southwest"
BG_genre_X_position="+19"
BG_genre_Y_position="+190"
#========================================================
 
#                Images Source
#========================================================
Kometa_shape="$APP_DIR/images/Kometa-shape.png"
Kometa_shadow="$APP_DIR/images/Kometa-shadow.png"
rating_background="$APP_DIR/images/Kometa-rating.png"
genre_background="$APP_DIR/images/Kometa-genre.png"
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

LAYER_POSTER=( \( "$inputfile" -scale "${poster_size}\!" -background none -gravity "$poster_gravity" -geometry "${poster_Y_position}${poster_X_position}" "$Kometa_shape" \) -compose Over -composite \( "$Kometa_shadow" -scale 512x512\! \) -compose over -composite )

LAYER_ICON_SIZE=( -define icon:auto-resize="$TemplateIconSize" )

LAYER_RATING_BG=()
LAYER_RATING=()
if [[ "$display_MovieInfo" == "yes" ]]; then
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
            LAYER_RATING_BG=( \( "$rating_background" -scale "${BG_rating_size}\!" -gravity "$BG_rating_gravity" -geometry "${BG_rating_Y_position}${BG_rating_X_position}" \) -compose Over -composite )
            if [[ -n "$rating" ]]; then
                LAYER_RATING=( \( -font "$rating_font_style" -fill "$rating_font_color" -density 400 -pointsize "$rating_font_size" -kerning 0 -gravity "$rating_gravity" -geometry "${rating_Y_position}${rating_X_position}" label:"$rating" \) -compose Over -composite )
            fi
        fi
    fi
fi

LAYER_GENRE_BG=()
LAYER_GENRE=()
if [[ "$display_MovieInfo" == "yes" ]] && [[ "$show_Genre" == "yes" ]] && [[ -n "$genre" ]]; then
    LAYER_GENRE_BG=( \( "$genre_background" -scale "${BG_genre_size}\!" -gravity "$BG_genre_gravity" -geometry "${BG_genre_Y_position}${BG_genre_X_position}" \) -compose Over -composite )
    LAYER_GENRE=( \( -font "$genre_font_style" -fill "$genre_font_color" -density 400 -pointsize "$genre_font_size" -kerning 0 -gravity "$genre_gravity" -geometry "${genre_Y_position}${genre_X_position}" label:"$genre" \) -compose Over -composite )
fi

shopt -u nocasematch

"$IM_CMD" \
  "${LAYER_BACKGROUND[@]}" \
  "${LAYER_POSTER[@]}" \
  "${LAYER_RATING_BG[@]}" \
  "${LAYER_RATING[@]}" \
  "${LAYER_GENRE_BG[@]}" \
  "${LAYER_GENRE[@]}" \
  "${LAYER_ICON_SIZE[@]}" \
  "$OutputFile"
