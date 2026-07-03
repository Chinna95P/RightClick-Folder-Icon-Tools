#!/bin/bash
# Template-Version=v1.3
# 2024-06-22 Fixed: Star image rendering in folder icon even without a ".nfo" file.
# 2024-06-24 Added: Global config to override template settings using RCFI.template.ini.
# 2024-06-24 Added: Gradient brightness, gradient shadow, and bevel shadow.
# 2024-12-23 Added: Option to customize folder names.


#                Template Info
#========================================================
#` Windows 11 style folder icon.
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

#--------- Folder Name --------------------
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
FolderNameShort_Pos_Left_Direction="SouthWest"
FolderNameShort_Pos_Left_X="-18"
FolderNameShort_Pos_Left_Y="+360"

# Folder name position when it's on the center
FolderNameShort_Pos_Center_Direction="Center"
FolderNameShort_Pos_Center_X="-148"
FolderNameShort_Pos_Center_Y="-167"

FolderNameLong_characters_limit="20"
FolderNameLong_font="Microsoft-PhagsPa"
FolderNameLong_size="3.5"
FolderNameLong_Pos_Direction="Northwest"
FolderNameLong_Pos_X="-15"
FolderNameLong_Pos_Y="+75"
FolderName_Font_Color="rgba(255,255,255,0.9)"

#--------- Additional Config --------------
Picture_Opacity="100%"

Background_Brightness="5"
Background_Contrast="20"
Background_Exposure="105"
Background_Saturation="150"
Background_Blur="200"
Background_AmbientColor="2"

Bevel_Brightness="25"
Bevel_Contrast="10"
Bevel_Exposure="110"
Bevel_Saturation="110"

Gradient_Brightness="20"
Gradient_Contrast="10"
Gradient_Exposure="110"
Gradient_Saturation="110"
#========================================================


#                Images Source
#========================================================
Win11_Back="$APP_DIR/images/Win11A-Back.png"
Win11_Back_Gradient="$APP_DIR/images/Win11A-Back-Gradient.png"
Win11_Front="$APP_DIR/images/Win11A-Front.png"
Win11_Front_Gradient="$APP_DIR/images/Win11A-Front-Gradient.png"
Win11_Front_GradientShadow="$APP_DIR/images/Win11A-Front-GradientShadow.png"
Win11_Front_Bevel="$APP_DIR/images/Win11A-Front-Bevel.png"
Win11_Front_BevelShadow="$APP_DIR/images/Win11A-Front-BevelShadow.png"
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
    # Start custom foldername prompt via kdialog if applicable, this needs equivalent logic from rcfi-tools.sh
    # Assuming custom_foldername.txt might be generated prior or here.
    if [[ -x "$APP_DIR/linux/resources/custom_foldername.sh" ]]; then
        "$APP_DIR/linux/resources/custom_foldername.sh"
    fi
    if [[ -f "$cfn1" ]]; then
        source "$cfn1"
        rm -f "$cfn1"
    fi
fi

LAYER_BACKGROUND=( \( "$canvas" -scale 512x512\! -background none -extent 512x512 \) -compose Over )

PicOp=$(echo "scale=0; 255 * ${Picture_Opacity%\%} / 100" | bc)
Picture_Opacity_Arg="-alpha set -channel A -evaluate set $PicOp +channel"
PicOpBevel=$((PicOp + 30))
if [[ $PicOpBevel -gt 255 ]]; then PicOpBevel=255; fi
Picture_Opacity_Bevel="-alpha set -channel A -evaluate set $PicOpBevel +channel"

LAYER_FRONT=( \
     \( "$inputfile" -scale 498x320\! -gravity Northwest -geometry +5+117 $Picture_Opacity_Arg "$Win11_Front" \) -compose over -composite \
     \( "$inputfile" -scale 498x320\! -gravity Northwest -geometry +5+117 -brightness-contrast -9x10 $Picture_Opacity_Bevel "$Win11_Front_BevelShadow" \) -compose over -composite \
     \( "$inputfile" -scale 498x320\! -gravity Northwest -geometry +5+117 -modulate "${Bevel_Exposure},${Bevel_Saturation}" -brightness-contrast "${Bevel_Brightness}x${Bevel_Contrast}" $Picture_Opacity_Bevel "$Win11_Front_Bevel" \) -compose over -composite \
     \( "$inputfile" -scale 498x320\! -gravity Northwest -geometry +5+117 -brightness-contrast "${Gradient_Brightness}x${Gradient_Contrast}" -modulate "${Gradient_Exposure},${Gradient_Saturation}" $Picture_Opacity_Arg "$Win11_Front_Gradient" \) -compose over -composite \
     \( "$inputfile" -scale 498x320\! -gravity Northwest -geometry +5+117 -brightness-contrast -0x10 -modulate 94,100 $Picture_Opacity_Arg "$Win11_Front_GradientShadow" \) -compose over -composite \
)

if [[ "$Background_AmbientColor" == "0" ]]; then
    LAYER_BACK=( \( "$Win11_Back" -scale 512x512\! \) -compose over -composite )
else
    LAYER_BACK=( \
         \( "$inputfile" -resize "${Background_AmbientColor}x${Background_AmbientColor}\!" -resize 1000x1000\! -scale 390x390\! -gravity Center -modulate "${Background_Exposure},${Background_Saturation}" -brightness-contrast -10x0 -blur "0x${Background_Blur}" -brightness-contrast "${Background_Brightness}x${Background_Contrast}" -modulate 95,100 "$Win11_Back" -scale 512x512\! \) -compose over -composite \
         \( "$inputfile" -resize "${Background_AmbientColor}x${Background_AmbientColor}\!" -resize 1000x1000\! -scale 390x390\! -gravity Center -modulate "100,${Background_Saturation}" -blur "0x${Background_Blur}" -brightness-contrast "${Background_Brightness}x${Background_Contrast}" -brightness-contrast -50x10 "$Win11_Back_Gradient" -scale 512x512\! \) -compose over -composite \
    )
fi

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
    LAYER_GENRE=( \( -font "$APP_DIR/resources/ANGIE-BOLD.TTF" -fill BLACK -density 400 -pointsize 5 -kerning 0 -gravity Northwest -geometry +79+400 label:"$genre" \( +clone -background ORANGE -shadow 70x1.2+2.6+2.6 \) +swap -background none -layers merge \( +clone -background YELLOW -shadow 70x1.2-2.6-2.6 \) +swap -background none -layers merge \( +clone -background ORANGE -shadow 70x1.2-2.6+2.6 \) +swap -background none -layers merge \( +clone -background ORANGE -shadow 70x1.2+2.6-2.6 \) +swap -background none -layers merge \( +clone -background BLACK -shadow 0x0.2+4+5 \) +swap -background none -layers merge \) -composite )
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

if [[ -n "$Logo" ]]; then
    LAYER_LOGO_IMAGE=( \( "$Logo" -trim +repage -scale 168x64^ -background none -gravity center -geometry -147-155 \) -compose Over -composite )
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
    LAYER_CLEARART_IMAGE=( \( "$ClearArt" -trim +repage -scale 260x117^ -background none -gravity South -geometry +90+392 \) -compose Over -composite )
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
    
    FolNamCenter=( -gravity "$FolderNameShort_Pos_Center_Direction" -geometry "${FolderNameShort_Pos_Center_X}${FolderNameShort_Pos_Center_Y}" )
    FolNamLeft=( -gravity "$FolderNameShort_Pos_Left_Direction" -geometry "${FolderNameShort_Pos_Left_X}${FolderNameShort_Pos_Left_Y}" )
    
    if [[ ${#foldername} -le $((FolderNameShort_characters_limit - 4)) ]]; then
        FolNamPos=( "${FolNamLeft[@]}" )
    else
        FolNamPos=( "${FolNamCenter[@]}" )
    fi
    if [[ "$FolderName_Center" == "yes" ]]; then FolNamPos=( "${FolNamCenter[@]}" ); fi
    if [[ "$FolderName_Center" == "no" ]]; then FolNamPos=( "${FolNamLeft[@]}" ); fi
    
    LAYER_FOLDER_NAME_SHORT=( \
         \( -font "$FolderNameShort_font" -fill "rgba(255,255,255,0.85)" -density 400 -pointsize "$FolderNameShort_size" "${FolNamPos[@]}" -background none label:"$FolNamShort" \( +clone -background BLACK -shadow 0x5+0.6+0.6 \) +swap -background none -layers merge \( +clone -background BLACK -shadow 0x5-0.6-0.6 \) +swap -background none -layers merge \( +clone -background BLACK -shadow 0x5-0.6+0.6 \) +swap -background none -layers merge \( +clone -background BLACK -shadow 0x5+0.6-0.6 \) +swap -background none -layers merge \) -composite \
    )
    
    if [[ ${#foldername} -gt $FolderNameShort_characters_limit ]] && [[ "$FolderNameLong_characters_limit" -ne 0 ]]; then
        LAYER_FOLDER_NAME_LONG=( \
             \( -font "$FolderNameLong_font" -fill "$FolderName_Font_Color" -density 400 -pointsize "$FolderNameLong_size" -kerning -0.5 -gravity "$FolderNameLong_Pos_Direction" -geometry "${FolderNameLong_Pos_X}${FolderNameLong_Pos_Y}" label:"$FolNamLong" \( +clone -background BLACK -shadow 0x5+0.2+0.2 \) +swap -background none -layers merge \( +clone -background BLACK -shadow 0x5-0.2-0.2 \) +swap -background none -layers merge \( +clone -background BLACK -shadow 0x5-0.2+0.2 \) +swap -background none -layers merge \( +clone -background BLACK -shadow 0x5+0.2-0.2 \) +swap -background none -layers merge \) -composite \
        )
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
