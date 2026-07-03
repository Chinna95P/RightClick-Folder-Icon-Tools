#!/bin/bash
# Template-Version=v1.3
# 2024-06-22 Fixed: Star image rendering in folder icon even without an ".nfo" file.
# 2024-06-24 Added: "Global Config" to override template settings via 'RCFI.template.ini'.
# 2024-10-20 Removed: "Picture-opacity" option to prevent black rendering on transparency.
# 2024-10-20 Added: "Picture-Drawing=original" to display images without modification.
# 2024-10-20 Added: Config option to adjust shadow settings.
# 2024-12-23 Added: Option to customize folder names.


#                Template Info
#========================================================
#` This template was inspired by Folderify 
#` https://github.com/lgarron/folderify
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
FolderNameLong_Pos_Gravity="SouthWest"
FolderNameLong_Pos_X="+3"
FolderNameLong_Pos_Y="+333"
FolderName_Font_Color="rgba(255,255,255,0.9)"

#--------- Picture Config -----------------
Picture_Drawing="yes"
   # Options: original = display the picture as is.
   #               yes = display as a grayscale picture.
   #               no  = convert everything to black, except for transparency.
   
Picture_TrimTransparentSpace="yes"
Picture_Width="340"
Picture_Height="190"
Picture_Gravity="center"
Picture_Position_X="-0"
Picture_Position_Y="+25"

	#--------- if "Picture Drawing=yes"
	  Picture_Drawing_ON_Brightness="-8"
	  Picture_Drawing_ON_Contrast="40"
	  Picture_Drawing_ON_Exposure="55"
	  Picture_Drawing_ON_Saturation="80"
	  Picture_Drawing_ON_Smoothness="0"

	#--------- if "Picture Drawing=NO"
	  Picture_Drawing_OFF_Brightness="-5"
	  Picture_Drawing_OFF_Contrast="15"
	  Picture_Drawing_OFF_Exposure="60"
	  Picture_Drawing_OFF_Saturation="100"
	  Picture_Drawing_OFF_Smoothness="15"

Picture_Shadow="yes"
Shadow_Color="BLACK"
Shadow_Opacity="20"
Shadow_Blur="0.6"

ReAdjust_BG_position="yes"
#========================================================


#                Images Source
#========================================================
Win11Folderify_BG="$APP_DIR/images/Win11Folderify.png"
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

LAYER_BACKGROUND=( \( "$canvas" -scale 512x512\! -background none -extent 512x512 \) -compose Over )

if [[ "$ReAdjust_BG_position" != "yes" ]]; then
    ReAdjust_Position=( -resize 512x512^ -gravity center -extent 512x512\! )
else
    ReAdjust_Position=( -trim +repage -resize x352 -gravity South -geometry -0+92 -extent 512x512\! )
fi

LAYER_FOLDERIFY=( \( "$Win11Folderify_BG" "${ReAdjust_Position[@]}" \) -compose over -composite )

TrimPNG=()
if [[ "$Picture_TrimTransparentSpace" == "yes" ]]; then TrimPNG=( -trim +repage ); fi

# Creating mask to carve the picture
Win11FolderifyMask="/tmp/Win11FolderifyMask-$$.png"

PictureIntensity=()
Picture_Drawing_Arg=()
if [[ "$Picture_Drawing" == "yes" ]]; then
    PictureIntensity=( -modulate "${Picture_Drawing_ON_Exposure},${Picture_Drawing_ON_Saturation}" -brightness-contrast "${Picture_Drawing_ON_Brightness}x${Picture_Drawing_ON_Contrast}" -blur "0x${Picture_Drawing_ON_Smoothness}" )
    Picture_Drawing_Arg=( -modulate 95,70 -brightness-contrast 0x10 -background white -channel a -alpha remove -channel rgb -negate -alpha shape )
elif [[ "$Picture_Drawing" != "original" ]]; then
    Picture_Drawing_Arg=()
    PictureIntensity=( -modulate "${Picture_Drawing_OFF_Exposure},${Picture_Drawing_OFF_Saturation}" -brightness-contrast "${Picture_Drawing_OFF_Brightness}x${Picture_Drawing_OFF_Contrast}" -blur "0x${Picture_Drawing_OFF_Smoothness}" )
fi

Picture_Shadow_Code=()
if [[ "$Picture_Shadow" != "no" ]]; then
    Picture_Shadow_Code=( \
         \( +clone -background "$Shadow_Color" -shadow "${Shadow_Opacity}x${Shadow_Blur}+4.5+2.0" \) +swap -background none -layers merge \
         \( +clone -background "$Shadow_Color" -shadow "${Shadow_Opacity}x${Shadow_Blur}-0.1-0.1" \) +swap -background none -layers merge \
         \( +clone -background "$Shadow_Color" -shadow "${Shadow_Opacity}x${Shadow_Blur}-0.1+0.1" \) +swap -background none -layers merge \
         \( +clone -background "$Shadow_Color" -shadow "${Shadow_Opacity}x${Shadow_Blur}+0.1-0.1" \) +swap -background none -layers merge \
    )
fi

if [[ "$Picture_Drawing" != "original" ]]; then
    "$IM_CMD" \( "$canvas" -scale 512x512\! -background none -extent 512x512 \) -compose Over \
	\( "$inputfile" "${TrimPNG[@]}" "${Picture_Drawing_Arg[@]}" -scale "${Picture_Width}x${Picture_Height}^" -gravity "$Picture_Gravity" -geometry "${Picture_Position_X}${Picture_Position_Y}" "${Picture_Shadow_Code[@]}" \) -compose over -composite "$Win11FolderifyMask"
	 
    LAYER_PICTURE=( \( "$Win11Folderify_BG" "${ReAdjust_Position[@]}" -scale 512x512\! "${PictureIntensity[@]}" "$Win11FolderifyMask" \) -compose Over -composite )
else
    LAYER_PICTURE=( \( "$inputfile" -scale "${Picture_Width}x${Picture_Height}^" -gravity "$Picture_Gravity" -geometry "${Picture_Position_X}${Picture_Position_Y}" "${Picture_Shadow_Code[@]}" \) -compose Over -composite )
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

Win11FolderifyLogoMask="/tmp/Win11FolderifyLogoMask-$$.png"
if [[ -n "$Logo" ]]; then
    "$IM_CMD" \( "$canvas" -scale 512x512\! -background none -extent 512x512 \) -compose Over \
	\( "$Logo" -trim +repage \( +clone -background BLACK -shadow 40x0.9+8.0+5.5 \) +swap -background none -layers merge \( +clone -background BLACK -shadow 40x0.9-2.7-2.7 \) +swap -background none -layers merge \( +clone -background BLACK -shadow 40x0.9-2.7+2.7 \) +swap -background none -layers merge \( +clone -background BLACK -shadow 40x0.9+2.7-2.7 \) +swap -background none -layers merge -modulate 95,70 -brightness-contrast 0x10 -background white -channel a -alpha remove -channel rgb -negate -alpha shape -scale 165x68^ -gravity center -geometry -134-150 \) -compose over -composite "$Win11FolderifyLogoMask"
	
    LAYER_LOGO_IMAGE=( \( "$Win11Folderify_BG" "${ReAdjust_Position[@]}" -scale 512x512\! -modulate 60,120 -brightness-contrast -5x30 -blur 0x1 "$Win11FolderifyLogoMask" \) -compose Over -composite )
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
  "${LAYER_FOLDERIFY[@]}" \
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
  
rm -f "$Win11FolderifyMask" "$Win11FolderifyLogoMask"
