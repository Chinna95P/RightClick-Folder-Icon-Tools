#!/bin/bash
# Template-Version=v1.3
# 2024-06-27 Added: Error handling for "LabelExpected ' @ error/annotate.c/GetMultilineTypeMetrics/804."
# 2024-12-23 Added: Option to customize folder names.


#                Template Info
#========================================================
#` Windows 11 theme folder icon.
#` ------------------------------------------------------


#                Template Config
#========================================================
use_GlobalConfig="yes"
custom_FolderName="no"

#--------- Movie Info ---------------------
display_movieinfo="yes"
show_Rating="yes"
preferred_rating="imdb"
show_Genre="yes"
genre_characters_limit="32"

#--------- Additional Art -----------------
use_Logo_instead_FolderName="yes"
display_clearArt="yes"

#--------- Folder Name --------------------------
display_FolderName="yes"
FolderName_Center="Auto"
    # options: Auto = Automatically put folder name on the center if numbers 
    #                 of the characters is less than half of characters limit
    #          yes  = Always put folder name on the center
    #          No   = Always put folder name on the left

FolderNameShort_characters_limit="7"
FolderNameShort_font="Microsoft-PhagsPa-Bold"
FolderNameShort_size="7.7"

# Folder name position when it's on the left
FolderNameShort_Pos_Left_Gravity="SouthWest"
FolderNameShort_Pos_Left_X="+34"
FolderNameShort_Pos_Left_Y="+385"

# Folder name position when it's on the center
FolderNameShort_Pos_Center_Gravity="Center"
FolderNameShort_Pos_Center_X="-137"
FolderNameShort_Pos_Center_Y="-161"

FolderNameLong_characters_limit="19"
FolderNameLong_font="Microsoft-PhagsPa"
FolderNameLong_size="3.5"
FolderNameLong_Pos_Gravity="NorthWest"
FolderNameLong_Pos_X="+0"
FolderNameLong_Pos_Y="+83"
FolderName_Font_Color="rgba(255,255,255,0.9)"

#--------- Picture Config -----------------
Picture_Opacity="100%"

Picture_Width="458"
Picture_Height="295"
Picture_Gravity="center"
Picture_Position_X="+1"
Picture_Position_Y="+14"

Picture_Drawing_Brightness="-20"
Picture_Drawing_Contrast="35"
Picture_Drawing_Exposure="50"
Picture_Drawing_Saturation="100"
Picture_Drawing_Smoothness="0"

#========================================================


#                Images Source
#========================================================
Win11Cover_Front="$APP_DIR/images/Win11Cover-Front.png"
Win11Cover_BG="$APP_DIR/images/Win11Cover.png"
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

cfn1="$APP_DIR/linux/resources/custom_foldername.txt"
if [[ "$custom_FolderName" == "yes" ]]; then
    if [[ -x "$APP_DIR/linux/resources/custom_foldername.sh" ]]; then
        "$APP_DIR/linux/resources/custom_foldername.sh"
    fi
    if [[ -f "$cfn1" ]]; then
        source "$cfn1"
        rm -f "$cfn1"
    fi
fi

LAYER_BACKGROUND=( \( "$canvas" -scale 512x512\! -background none -extent 512x512 \) -compose Over \( "$Win11Cover_BG" \) -compose over -composite )

# Creating mask to carve the picture
Win11CoverMask="/tmp/Win11CoverMask-$$.png"

"$IM_CMD" \
	\( "$canvas" -scale 512x512\! -background none -extent 512x512 \) -compose Over \
	\( "$inputfile" -scale "${Picture_Width}x${Picture_Height}\!" -gravity "$Picture_Gravity" -geometry "${Picture_Position_X}${Picture_Position_Y}" "$Win11Cover_Front" \) -compose over -composite "$Win11CoverMask"

"$IM_CMD" "$Win11CoverMask" \
	-brightness-contrast 0x10 -modulate 95,70 -background white -channel a -alpha remove -channel rgb -negate -alpha shape \
	"$Win11CoverMask"

PicOp=$(echo "scale=0; 255 * ${Picture_Opacity%\%} / 100" | bc)
Picture_Opacity_Arg="-alpha set -channel A -evaluate set $PicOp +channel"

LAYER_PICTURE=( \( "$Win11Cover_BG" -scale 512x512\! -modulate "${Picture_Drawing_Exposure},${Picture_Drawing_Saturation}" -brightness-contrast "${Picture_Drawing_Brightness}x${Picture_Drawing_Contrast}" -blur "0x${Picture_Drawing_Smoothness}" $Picture_Opacity_Arg "$Win11CoverMask" \) -compose Over -composite )
	  
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
            LAYER_STAR_IMAGE=( \( "$star_image" -scale 88x88\! -gravity Northwest -geometry +0+356 \( +clone -background BLACK -shadow 40x1.2+1.8+3 \) +swap -background none -layers merge -extent 512x512 \) -compose Over -composite )
            if [[ -n "$rating" ]]; then
                LAYER_RATING=( \( -font "$APP_DIR/resources/ANGIE-BOLD.TTF" -fill "rgba(0,0,0,0.9)" -density 400 -pointsize 6 -kerning 0 label:"$rating" -gravity Northwest -geometry +13+383 \( +clone -background ORANGE -shadow 30x1.2+2+2 \) +swap -background none -layers merge \( +clone -background YELLOW -shadow 30x1.2-2-2 \) +swap -background none -layers merge \( +clone -background ORANGE -shadow 30x1.2-2+2 \) +swap -background none -layers merge \( +clone -background ORANGE -shadow 30x1.2+2-2 \) +swap -background none -layers merge \) -compose Over -composite )
            fi
        fi
    fi
fi

LAYER_GENRE=()
if [[ "$display_movieinfo" == "yes" ]] && [[ "$show_Genre" == "yes" ]] && [[ -n "$genre" ]]; then
    LAYER_GENRE=( \( -font "$APP_DIR/resources/ANGIE-BOLD.TTF" -fill BLACK -density 400 -pointsize 5 -kerning 0 -gravity Northwest -geometry +76+395 label:"$genre" \( +clone -background ORANGE -shadow 70x1.2+2.6+2.6 \) +swap -background none -layers merge \( +clone -background YELLOW -shadow 70x1.2-2.6-2.6 \) +swap -background none -layers merge \( +clone -background ORANGE -shadow 70x1.2-2.6+2.6 \) +swap -background none -layers merge \( +clone -background ORANGE -shadow 70x1.2+2.6-2.6 \) +swap -background none -layers merge \( +clone -background BLACK -shadow 0x0.2+4+5 \) +swap -background none -layers merge \) -composite )
fi

LAYER_LOGO_IMAGE=()
Logo=""
if [[ "$use_Logo_instead_FolderName" == "yes" ]] && [[ "$custom_FolderName_HaveTheLogo" != "yes" ]]; then
    for D in *logo.png; do
        if [[ -f "$D" ]]; then
            Logo="$PWD/$D"
            break
        fi
    done
fi

Win11CoverLogoMask="/tmp/Win11CoverLogoMask-$$.png"

if [[ -n "$Logo" ]]; then
    "$IM_CMD" \( "$canvas" -scale 512x512\! -background none -extent 512x512 \) -compose Over \
	\( "$Logo" -trim +repage \( +clone -background BLACK -shadow 40x0.9+8.0+5.5 \) +swap -background none -layers merge \( +clone -background BLACK -shadow 40x0.9-2.7-2.7 \) +swap -background none -layers merge \( +clone -background BLACK -shadow 40x0.9-2.7+2.7 \) +swap -background none -layers merge \( +clone -background BLACK -shadow 40x0.9+2.7-2.7 \) +swap -background none -layers merge -modulate 95,70 -brightness-contrast 0x10 -background white -channel a -alpha remove -channel rgb -negate -alpha shape -scale 160x68^ -gravity center -geometry -138-150 \) -compose over -composite "$Win11CoverLogoMask"
	
    LAYER_LOGO_IMAGE=( \( "$Win11Cover_BG" -scale 512x512\! -modulate 60,120 -brightness-contrast -5x30 -blur 0x1 "$Win11CoverLogoMask" \) -compose Over -composite )
fi

LAYER_CLEARART_IMAGE=()
ClearArt=""
if [[ "$display_clearArt" == "yes" ]]; then
    for D in *clearart.png; do
        if [[ -f "$D" ]]; then
            ClearArt="$PWD/$D"
            break
        fi
    done
fi

if [[ -n "$ClearArt" ]]; then
    LAYER_CLEARART_IMAGE=( \( "$ClearArt" -trim +repage -scale 230x125^ -background none -gravity South -geometry +90+388 \) -compose Over -composite )
fi

LAYER_FOLDER_NAME_SHORT=()
LAYER_FOLDER_NAME_LONG=()

if [[ "$display_FolderName" == "yes" ]] && [[ -z "$Logo" ]]; then
    if [[ "$custom_FolderName" != "yes" ]]; then
        foldername="${PWD##*/}"
    fi
    if [[ -z "$foldername" ]]; then
        foldername="            "
        FolderNameLong_characters_limit=0
    fi
    
    FolNamShort="${foldername:0:$FolderNameShort_characters_limit}"
    if [[ ${#foldername} -gt $FolderNameShort_characters_limit ]]; then
        FolNamShort="${foldername:0:$((FolderNameShort_characters_limit - 4))}..."
    fi
    
    FolNamLong="${foldername:0:$FolderNameLong_characters_limit}"
    if [[ ${#foldername} -gt $FolderNameLong_characters_limit ]]; then
        FolNamLong="${foldername:0:$((FolderNameLong_characters_limit - 4))}..."
    fi
    
    FolNamCenter=( -gravity "$FolderNameShort_Pos_Center_Gravity" -geometry "${FolderNameShort_Pos_Center_X}${FolderNameShort_Pos_Center_Y}" )
    FolNamLeft=( -gravity "$FolderNameShort_Pos_Left_Gravity" -geometry "${FolderNameShort_Pos_Left_X}${FolderNameShort_Pos_Left_Y}" )
    
    if [[ ${#foldername} -le $((FolderNameShort_characters_limit - 4)) ]]; then
        FolNamPos=( "${FolNamLeft[@]}" )
    else
        FolNamPos=( "${FolNamCenter[@]}" )
    fi
    if [[ "$FolderName_Center" == "yes" ]]; then FolNamPos=( "${FolNamCenter[@]}" ); fi
    if [[ "$FolderName_Center" == "no" ]]; then FolNamPos=( "${FolNamLeft[@]}" ); fi
    
    LAYER_FOLDER_NAME_SHORT=( \
         \( -font "$FolderNameShort_font" -fill "$FolderName_Font_Color" -density 400 -pointsize "$FolderNameShort_size" "${FolNamPos[@]}" -background none label:"$FolNamShort" \( +clone -background BLACK -shadow 0x1+0.3+0.3 \) +swap -background none -layers merge \( +clone -background BLACK -shadow 0x1-0.3-0.3 \) +swap -background none -layers merge \( +clone -background BLACK -shadow 0x1-0.3+0.3 \) +swap -background none -layers merge \( +clone -background BLACK -shadow 0x1+0.3-0.3 \) +swap -background none -layers merge \) -composite \
    )
    
    if [[ ${#foldername} -gt $FolderNameShort_characters_limit ]] && [[ "$FolderNameLong_characters_limit" -ne 0 ]]; then
        LAYER_FOLDER_NAME_LONG=( \
             \( -font "$FolderNameLong_font" -fill "$FolderName_Font_Color" -density 400 -pointsize "$FolderNameLong_size" -kerning -0.5 -gravity "$FolderNameLong_Pos_Gravity" -geometry "${FolderNameLong_Pos_X}${FolderNameLong_Pos_Y}" label:"$FolNamLong" \( +clone -background BLACK -shadow 0x4.5+0.2+0.2 \) +swap -background none -layers merge \( +clone -background BLACK -shadow 0x4.5-0.2-0.2 \) +swap -background none -layers merge \( +clone -background BLACK -shadow 0x4.5-0.2+0.2 \) +swap -background none -layers merge \( +clone -background BLACK -shadow 0x4.5+0.2-0.2 \) +swap -background none -layers merge \) -composite \
        )
    fi
fi

shopt -u nocasematch

"$IM_CMD" \
  "${LAYER_BACKGROUND[@]}" \
  "${LAYER_FOLDER_NAME_SHORT[@]}" \
  "${LAYER_FOLDER_NAME_LONG[@]}" \
  "${LAYER_LOGO_IMAGE[@]}" \
  "${LAYER_CLEARART_IMAGE[@]}" \
  "${LAYER_PICTURE[@]}" \
  "${LAYER_STAR_IMAGE[@]}" \
  "${LAYER_RATING[@]}" \
  "${LAYER_GENRE[@]}" \
  "${LAYER_ICON_SIZE[@]}" \
  "$OutputFile"
  
rm -f "$Win11CoverMask" "$Win11CoverLogoMask"
