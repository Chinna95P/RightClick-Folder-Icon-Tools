#!/bin/bash
# Template-Version=v1.3

#                Template Config
#========================================================
use_GlobalConfig="yes"
custom_FolderName="no"

#--------- Label --------------------------
display_FolderName="yes"
FolderNameShort_characters_limit="10"
FolderNameLong_characters_limit="36"
FolderName_Center="Auto"
FolderName_Font_Color="rgba(255,255,255,0.9)"

#--------- Movie Info ---------------------
display_movieinfo="yes"
show_Rating="yes"
preferred_rating="imdb"
show_Genre="yes"
genre_characters_limit="32"

#--------- Additional Art -----------------
use_Logo_instead_FolderName="yes"
display_clearArt="yes"
#========================================================

#                Images Source
#========================================================
folderhorizontal_top="$APP_DIR/images/folderhorizontal-top.png"
folderhorizontal_topfx="$APP_DIR/images/folderhorizontal-topfx.png"
folderhorizontal_topshadow="$APP_DIR/images/folderhorizontal-topshadow.png"
folderhorizontal_main="$APP_DIR/images/folderhorizontal-main.png"
folderhorizontal_mainfx="$APP_DIR/images/folderhorizontal-mainfx.png"
star_image="$APP_DIR/images/star.png"
canvas="$APP_DIR/images/- canvas.png"
#========================================================

shopt -s nocasematch

# LAYER-BASE
if [[ "$use_GlobalConfig" == "yes" ]] && [[ -f "$RCFI_templates_ini" ]]; then
    while IFS='=' read -r key value; do
        if [[ -n "$value" ]] && [[ "$value" != " " ]]; then
            key=$(echo "$key" | xargs | sed 's/-/_/g')
            value=$(echo "$value" | tr -d '\r' | xargs)
            export "$key=$value"
        fi
    done < "$RCFI_templates_ini"
fi

if [[ "$custom_FolderName" == "yes" ]]; then
    if [[ -x "$APP_DIR/linux/resources/custom_foldername.sh" ]]; then
        source "$APP_DIR/linux/resources/custom_foldername.sh"
    fi
fi

LAYER_BACKGROUND=( \( "$canvas" -scale 512x512\! -background none -extent 512x512 \) -compose Over )

LAYER_POSTER_MAIN=( \( "$inputfile" -scale 495x307\! -gravity Northwest -geometry +8+141 "$folderhorizontal_main" \) -compose over -composite \( "$folderhorizontal_mainfx" -scale 512x512\! \) -compose over -composite )

LAYER_POSTER_TOP=( \( "$inputfile" -scale 512x512\! -blur 0x19 "$folderhorizontal_top" \) -compose over -composite \( "$folderhorizontal_topfx" -scale 512x512\! \) -compose over -composite )

LAYER_POSTER_TOP_SHADOW=( \( "$folderhorizontal_topshadow" -scale 512x512\! \) -compose over -composite )
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
            LAYER_STAR_IMAGE=( \( "$star_image" -scale 88x88\! -gravity Northwest -geometry +0+356 \( +clone -background BLACK -shadow 40x1.2+1.8+3 \) +swap -background none -layers merge -extent 512x512 \) -compose Over -composite )
            if [[ -n "$rating" ]]; then
                LAYER_RATING=( \( -font "$APP_DIR/resources/ANGIE-BOLD.TTF" -fill "rgba(0,0,0,0.9)" -density 400 -pointsize 6 -kerning 0 label:"$rating" -gravity Northwest -geometry +13+383 \( +clone -background ORANGE -shadow 30x1.2+2+2 \) +swap -background none -layers merge \( +clone -background YELLOW -shadow 30x1.2-2-2 \) +swap -background none -layers merge \( +clone -background ORANGE -shadow 30x1.2-2+2 \) +swap -background none -layers merge \( +clone -background ORANGE -shadow 30x1.2+2-2 \) +swap -background none -layers merge \) -compose Over -composite )
            fi
        fi
    fi
fi

# LAYER-GENRE
LAYER_GENRE=()
if [[ "$display_movieinfo" == "yes" ]] && [[ "$show_Genre" == "yes" ]] && [[ -n "$genre" ]]; then
    LAYER_GENRE=( \( -font "$APP_DIR/resources/ANGIE-BOLD.TTF" -fill BLACK -density 400 -pointsize 5 -kerning 0 -gravity Northwest -geometry +79+400 label:"$genre" \( +clone -background ORANGE -shadow 70x1.2+2.6+2.6 \) +swap -background none -layers merge \( +clone -background YELLOW -shadow 70x1.2-2.6-2.6 \) +swap -background none -layers merge \( +clone -background ORANGE -shadow 70x1.2-2.6+2.6 \) +swap -background none -layers merge \( +clone -background ORANGE -shadow 70x1.2+2.6-2.6 \) +swap -background none -layers merge \( +clone -background BLACK -shadow 0x0.2+4+5 \) +swap -background none -layers merge \) -composite )
fi

# LAYER-LOGO
LAYER_LOGO_IMAGE=()
if [[ "$use_Logo_instead_FolderName" == "yes" ]] && [[ "$custom_FolderName_HaveTheLogo" != "yes" ]]; then
    Logo=""
    for f in *logo.png; do
        if [[ -f "$f" ]]; then
            Logo="$PWD/$f"
            echo -e " \t \033[32mLogo        :\033[0m $(basename "$f")"
            break
        fi
    done
    if [[ -n "$Logo" ]]; then
        LAYER_LOGO_IMAGE=( \( "$Logo" -trim +repage -scale 162x48^ -background none -gravity center -geometry -125-147 \) -compose Over -composite )
    fi
fi

# LAYER-CLEARART
LAYER_CLEARART_IMAGE=()
if [[ "$display_clearArt" == "yes" ]]; then
    ClearArt=""
    for f in *clearart.png; do
        if [[ -f "$f" ]]; then
            ClearArt="$PWD/$f"
            echo -e " \t \033[32mClear Art   :\033[0m $(basename "$f")"
            break
        fi
    done
    if [[ -n "$ClearArt" ]]; then
        LAYER_CLEARART_IMAGE=( \( "$ClearArt" -trim +repage -scale 248x -background none -gravity Northwest -geometry +223+3 \) -compose Over -composite )
    fi
fi

# LAYER-FOLDER_NAME
LAYER_FOLDER_NAME_SHORT=()
LAYER_FOLDER_NAME_LONG=()
if [[ "$display_FolderName" == "yes" ]] && [[ ${#LAYER_LOGO_IMAGE[@]} -eq 0 ]]; then
    if [[ "$custom_FolderName" != "yes" ]]; then
        foldername=$(basename "$PWD")
    fi
    if [[ -z "$foldername" ]]; then
        foldername="${PWD//\//\\            }"
        FolderNameLong_characters_limit=0
    fi

    FolNamShort="$foldername"
    FolNamShortLimit="$FolderNameShort_characters_limit"
    if [[ ${#foldername} -gt $FolNamShortLimit ]]; then
        FolNamShortLimiter=$((FolNamShortLimit - 3))
        FolNamShort="${foldername:0:$FolNamShortLimiter}..."
    fi

    FolNamLong="$foldername"
    FolNamLongLimit="$FolderNameLong_characters_limit"
    if [[ ${#foldername} -gt $FolNamLongLimit ]]; then
        FolNamLongLimiter=$((FolNamLongLimit - 3))
        FolNamLong="${foldername:0:$FolNamLongLimiter}..."
    fi

    FolNamCenter=( -gravity center -geometry -122-152 )
    FolNamLeft=( -gravity Northwest -geometry +17+44 )
    
    FolNamPos=()
    if [[ ${#foldername} -le $((FolNamShortLimit - 3)) ]]; then
        FolNamPos=( "${FolNamLeft[@]}" )
    else
        FolNamPos=( "${FolNamCenter[@]}" )
    fi
    
    if [[ "$FolderName_Center" == "yes" ]]; then FolNamPos=( "${FolNamCenter[@]}" ); fi
    if [[ "$FolderName_Center" == "no" ]]; then FolNamPos=( "${FolNamLeft[@]}" ); fi

    LAYER_FOLDER_NAME_SHORT=( \( -font Arial-Bold -fill "$FolderName_Font_Color" -density 400 -pointsize 5.2 "${FolNamPos[@]}" -background none label:"$FolNamShort" \( +clone -background BLACK -shadow 10x5+0.6+0.6 \) +swap -background none -layers merge \( +clone -background BLACK -shadow 10x5-0.6-0.6 \) +swap -background none -layers merge \( +clone -background BLACK -shadow 10x5-0.6+0.6 \) +swap -background none -layers merge \( +clone -background BLACK -shadow 10x5+0.6-0.6 \) +swap -background none -layers merge \) -composite )

    if [[ ${#foldername} -gt $FolNamShortLimit ]] && [[ "$FolderNameLong_characters_limit" != "0" ]]; then
        LAYER_FOLDER_NAME_LONG=( \( -font Arial-Bold -fill "$FolderName_Font_Color" -density 400 -pointsize 3.1 -kerning 1.5 -gravity Northwest -geometry -5+79 label:"$FolNamLong" \( +clone -background BLACK -shadow 10x5+0.2+0.2 \) +swap -background none -layers merge \( +clone -background BLACK -shadow 10x5-0.2-0.2 \) +swap -background none -layers merge \( +clone -background BLACK -shadow 10x5-0.2+0.2 \) +swap -background none -layers merge \( +clone -background BLACK -shadow 10x5+0.2-0.2 \) +swap -background none -layers merge \) -composite )
    fi
fi

shopt -u nocasematch

"$IM_CMD" \
  "${LAYER_BACKGROUND[@]}" \
  "${LAYER_POSTER_TOP[@]}" \
  "${LAYER_FOLDER_NAME_SHORT[@]}" \
  "${LAYER_FOLDER_NAME_LONG[@]}" \
  "${LAYER_LOGO_IMAGE[@]}" \
  "${LAYER_CLEARART_IMAGE[@]}" \
  "${LAYER_POSTER_TOP_SHADOW[@]}" \
  "${LAYER_POSTER_MAIN[@]}" \
  "${LAYER_STAR_IMAGE[@]}" \
  "${LAYER_RATING[@]}" \
  "${LAYER_GENRE[@]}" \
  "${LAYER_ICON_SIZE[@]}" \
  "$OutputFile"
