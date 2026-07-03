#!/bin/bash
# Template-Version=v1.4

#                Template Config
#========================================================
use_GlobalConfig="yes"
custom_FolderName="no"

#--------- Label --------------------------
display_FolderName="yes"
FolderNameShort_characters_limit="11"
FolderNameShort_font="Arial-Bold"
FolderNameLong_characters_limit="38"
FolderNameLong_font="Arial"
FolderName_Center="Auto"
FolderName_Font_Color="rgba(255,255,255,0.9)"

#--------- Movie Info ---------------------
display_movieinfo="yes"
show_Rating="yes"
preferred_rating="imdb"
show_Genre="yes"
genre_characters_limit="31"

#--------- Additional Art -----------------
use_Logo_instead_FolderName="yes"
display_clearArt="yes"

#--------- Additional Config --------------
Picture_Opacity="100"
Background_Brightness="-5"
Background_Exposure="80"
Background_Contrast="27"
Background_Saturation="150"
Background_Blur="200"
Background_AmbientColor="2"
#========================================================

#                Images Source
#========================================================
BeOriginal_Back="$APP_DIR/images/BeOriginal-Back.png"
BeOriginal_BackFx="$APP_DIR/images/BeOriginal-BackFx.png"
BeOriginal_Front="$APP_DIR/images/BeOriginal-Front.png"
BeOriginal_FrontFx="$APP_DIR/images/BeOriginal-FrontFx.png"
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

PicOp=$(( 255 * Picture_Opacity / 100 ))
Picture_Opacity_Arg=( -alpha set -channel A -evaluate set $PicOp +channel )

LAYER_FRONT=( \( "$inputfile" -scale 480x318\! -gravity Northwest -geometry +18+124 "${Picture_Opacity_Arg[@]}" "$BeOriginal_Front" \) -compose over -composite \( "$BeOriginal_FrontFx" -scale 512x512\! \) -compose over -composite )
     
if [[ "$Background_AmbientColor" == "0" ]]; then
    LAYER_BACK=( \( "$inputfile" -scale 512x512\! \) -compose over -composite )
else
    LAYER_BACK=( \( "$inputfile" -modulate 100x$Background_Saturation -modulate ${Background_Exposure}x100 -brightness-contrast 0x5 -modulate 100x130 -resize ${Background_AmbientColor}x${Background_AmbientColor}\! -resize 1000x1000\! -scale 512x512\! -gravity Center -blur 0x$Background_Blur -brightness-contrast ${Background_Brightness}x0 -brightness-contrast 0x$Background_Contrast -blur 0x20 "$BeOriginal_Back" \) -compose over -composite \( "$BeOriginal_BackFx" -scale 512x512\! \) -compose over -composite )
fi
     
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
        LAYER_LOGO_IMAGE=( \( "$Logo" -trim +repage -scale 145x45^ -background none -gravity center -geometry -155-157 \) -compose Over -composite )
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
        LAYER_CLEARART_IMAGE=( \( "$ClearArt" -trim +repage -scale 295x123^ -background none -gravity South -geometry +90+383 \) -compose Over -composite )
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

    FolNamCenter=( -gravity center -geometry -155-165 )
    FolNamLeft=( -gravity Northwest -geometry -5+35 )
    
    FolNamPos=()
    if [[ ${#foldername} -le $((FolNamShortLimit - 3)) ]]; then
        FolNamPos=( "${FolNamLeft[@]}" )
    else
        FolNamPos=( "${FolNamCenter[@]}" )
    fi
    
    if [[ "$FolderName_Center" == "yes" ]]; then FolNamPos=( "${FolNamCenter[@]}" ); fi
    if [[ "$FolderName_Center" == "no" ]]; then FolNamPos=( "${FolNamLeft[@]}" ); fi

    LAYER_FOLDER_NAME_SHORT=( \( -font "$FolderNameShort_font" -fill "$FolderName_Font_Color" -density 400 -pointsize 4.5 "${FolNamPos[@]}" -background none label:"$FolNamShort" \( +clone -background BLACK -shadow 10x5+0.6+0.6 \) +swap -background none -layers merge \( +clone -background BLACK -shadow 10x5-0.6-0.6 \) +swap -background none -layers merge \( +clone -background BLACK -shadow 10x5-0.6+0.6 \) +swap -background none -layers merge \( +clone -background BLACK -shadow 10x5+0.6-0.6 \) +swap -background none -layers merge \) -composite )

    if [[ ${#foldername} -gt $FolNamShortLimit ]] && [[ "$FolderNameLong_characters_limit" != "0" ]]; then
        LAYER_FOLDER_NAME_LONG=( \( -font "$FolderNameLong_font" -fill "$FolderName_Font_Color" -density 400 -pointsize 2.5 -kerning 2 -gravity Northwest -geometry +1+68 label:"$FolNamLong" \( +clone -background BLACK -shadow 10x5+0.2+0.2 \) +swap -background none -layers merge \( +clone -background BLACK -shadow 10x5-0.2-0.2 \) +swap -background none -layers merge \( +clone -background BLACK -shadow 10x5-0.2+0.2 \) +swap -background none -layers merge \( +clone -background BLACK -shadow 10x5+0.2-0.2 \) +swap -background none -layers merge \) -composite )
    fi
fi

shopt -u nocasematch

"$IM_CMD" \
  "${LAYER_BACKGROUND[@]}" \
  "${LAYER_BACK[@]}" \
  "${LAYER_FOLDER_NAME_SHORT[@]}" \
  "${LAYER_FOLDER_NAME_LONG[@]}" \
  "${LAYER_LOGO_IMAGE[@]}" \
  "${LAYER_CLEARART_IMAGE[@]}" \
  "${LAYER_FRONT[@]}" \
  "${LAYER_STAR_IMAGE[@]}" \
  "${LAYER_RATING[@]}" \
  "${LAYER_GENRE[@]}" \
  "${LAYER_ICON_SIZE[@]}" \
  "$OutputFile"
