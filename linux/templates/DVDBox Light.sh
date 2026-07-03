#!/bin/bash
# Template-Version=v1.2

#                Template Config
#========================================================
use_GlobalConfig="Yes"

display_DiscImage="yes"
DiscArt_search="*discart.png"
generate_DiscArt="yes"
generate_DiscArt_search="*poster*.jpg *landscape*.jpg *fanart*.jpg"

display_MovieInfo="yes"
show_Rating="yes"
preferred_rating="imdb"
show_Genre="yes"
genre_characters_limit="31"
#========================================================

#                Images Source
#========================================================
frame_image="$APP_DIR/images/dvdbox-light.png"
star_image="$APP_DIR/images/star.png"
disc_image="$APP_DIR/images/disc-vinyl.png"
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

LAYER_POSTER_IMAGE=( \( "$inputfile" -scale 340x483\! -background none -gravity Northwest -geometry +7+11 \) -compose Over -composite )

LAYER_FRAME_IMAGE=( \( "$frame_image" -resize 512x512\! \) -compose Over -composite )

LAYER_ICON_SIZE=( -define icon:auto-resize="$TemplateIconSize" )

# LAYER-DISC
LAYER_DISC_IMAGE=()
if [[ "$display_DiscImage" == "yes" ]]; then
    if [[ -z "$generate_DiscArt_search" ]]; then
        generate_DiscArt_search="$inputfile"
    fi

    discart=""
    for ext in $DiscArt_search; do
        for f in $ext; do
            if [[ -f "$f" ]]; then
                discart="$PWD/$f"
                echo -e " \t \033[32mDisc Art    :\033[0m $(basename "$f")"
                break 2
            fi
        done
    done

    if [[ -z "$discart" ]] && [[ "$generate_DiscArt" == "yes" ]]; then
        export referrer="DVDcase"
        export gen_disc=""
        for ext in $generate_DiscArt_search "$inputfile"; do
            for f in $ext; do
                if [[ -f "$f" ]]; then
                    for sup in "${ImageSupport[@]}"; do
                        if [[ "${f##*.}" == "${sup##*.}" ]]; then
                            export gen_disc="$PWD/$f"
                            echo -e " \t \033[32mDisc Art    :\033[0m $(basename "$f")"
                            break 3
                        fi
                    done
                fi
            done
        done
        
        if [[ -n "$gen_disc" ]]; then
            if [[ ! -f "$APP_DIR/linux/templates/DiscArt.sh" ]]; then
                echo -e " \t \033[31mDiscArt Template not found.\033[0m"
            else
                source "$APP_DIR/linux/templates/DiscArt.sh"
                discart="$PWD/$DiscArt"
            fi
        fi
    fi
    
    if [[ -z "$discart" ]]; then
        discart="$disc_image"
    fi
    
    LAYER_DISC_IMAGE=( \( "$discart" -scale 340x340\! -background none -extent 512x512-164-84 \( +clone -background BLACK -shadow 100x1.3+2+2 \) +swap -background none -layers merge -extent 512x512 \) -compose Over -composite )
fi

# LAYER-RATING
LAYER_STAR_IMAGE=()
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
            LAYER_STAR_IMAGE=( \( "$star_image" -scale 88x88\! -extent 512x512-0-410 \( +clone -background BLACK -shadow 40x1.2+1.8+3 \) +swap -background none -layers merge -extent 512x512 \) -compose Over -composite )
            
            if [[ -n "$rating" ]]; then
                LAYER_RATING=( \( -font "$APP_DIR/resources/ANGIE-BOLD.TTF" -fill "rgba(0,0,0,0.9)" -density 400 -pointsize 6 label:"$rating" -gravity Northwest -geometry +13+435 \( +clone -background ORANGE -shadow 30x1.2+2+2 \) +swap -background none -layers merge \( +clone -background YELLOW -shadow 30x1.2-2-2 \) +swap -background none -layers merge \( +clone -background ORANGE -shadow 30x1.2-2+2 \) +swap -background none -layers merge \( +clone -background ORANGE -shadow 30x1.2+2-2 \) +swap -background none -layers merge \) -compose Over -composite )
            fi
        fi
    fi
fi

# LAYER-GENRE
LAYER_GENRE=()
if [[ "$display_MovieInfo" == "yes" ]] && [[ "$show_Genre" == "yes" ]] && [[ -n "$genre" ]]; then
    LAYER_GENRE=( \( -font "$APP_DIR/resources/ANGIE-BOLD.TTF" -fill BLACK -density 400 -pointsize 5 -gravity NorthWest -geometry +74+452 label:"$genre" \( +clone -background ORANGE -shadow 70x1.2+2.7+2.7 \) +swap -background none -layers merge \( +clone -background YELLOW -shadow 70x1.2-2.7-2.7 \) +swap -background none -layers merge \( +clone -background ORANGE -shadow 70x1.2-2.7+2.7 \) +swap -background none -layers merge \( +clone -background ORANGE -shadow 70x1.2+2.7-2.7 \) +swap -background none -layers merge \( +clone -background BLACK -shadow 0x0.2+4+5 \) +swap -background none -layers merge \) -composite )
fi

shopt -u nocasematch

"$IM_CMD" \
  "${LAYER_BACKGROUND[@]}" \
  "${LAYER_DISC_IMAGE[@]}" \
  "${LAYER_POSTER_IMAGE[@]}" \
  "${LAYER_FRAME_IMAGE[@]}" \
  "${LAYER_STAR_IMAGE[@]}" \
  "${LAYER_RATING[@]}" \
  "${LAYER_GENRE[@]}" \
  "${LAYER_ICON_SIZE[@]}" \
  "$OutputFile"

if [[ -n "$deltemp" ]]; then
    eval "$deltemp"
    deltemp=""
fi
