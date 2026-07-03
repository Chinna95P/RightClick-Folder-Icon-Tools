#!/bin/bash
# Template-Version=v1.1

#                Template Config
#========================================================
use_GlobalConfig="no"
custom_FolderName="yes"
 
#--------- Label --------------------------
display_FolderName="yes"
FolderNameShort_characters_limit="10"
FolderNameLong_characters_limit="38"
FolderName_Center="Auto"
FolderName_Font_Color="rgba(255,255,255,0.9)"
FolderName_Pos_Short_Center="-gravity center -geometry +205-69"
Foldername_Pos_Short_Left="-gravity Northwest -geometry +422+92"
Foldername_Pos_Long="-gravity Northwest -geometry +382-3"
FolderName_Pos_Tab2="-gravity center -geometry +207+88"

Tab2_FontSize="5"
Tab2_FontSpacing="3"
Tab2_Shadow="35x0.9"

#--------- Movie Info ---------------------
display_movieinfo="yes"
show_Rating="yes"
preferred_rating="imdb"
show_Genre="yes"
genre_characters_limit="26"

#--------- Additional Art -----------------
use_Logo_instead_FolderName="yes"
display_clearArt="no"
#========================================================

#                Images Source
#========================================================
DualTabV_front="$APP_DIR/images/DualTabV-Front.png"
DualTabV_frontfx="$APP_DIR/images/DualTabV-FrontFX.png"
DualTabV_tab1="$APP_DIR/images/DualTabV-Tab1.png"
DualTabV_tab1fx="$APP_DIR/images/DualTabV-Tab1FX.png"
DualTabV_tab2="$APP_DIR/images/DualTabV-Tab2.png"
DualTabV_tab2fx="$APP_DIR/images/DualTabV-Tab2FX.png"
DualTabV_shadow="$APP_DIR/images/DualTabV-DropShadow.png"
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

multi_FolderName="yes"
if [[ "$custom_FolderName" == "yes" ]]; then
    if [[ -x "$APP_DIR/linux/resources/custom_foldername.sh" ]]; then
        source "$APP_DIR/linux/resources/custom_foldername.sh"
    fi
fi

LAYER_BACKGROUND=( \( "$canvas" -scale 512x512\! -background none -extent 512x512 \) -compose Over )

LAYER_POSTER_MAIN=( \( "$inputfile" -resize 372x482^ -gravity South -extent 372x482 -brightness-contrast 5x15 -modulate 100,110 -gravity Northwest -geometry +51+4 "$DualTabV_front" \) -compose over -composite \( "$DualTabV_frontfx" -scale 512x512\! \) -compose over -composite )

LAYER_TAB1=( \( "$inputfile" -resize 3x3\! -resize 1000x1000\! -scale 512x512\! -modulate 100,130 -brightness-contrast 8x13 -blur 0x50 "$DualTabV_tab1" \) -compose over -composite )
LAYER_TAB1_FX=( \( "$DualTabV_tab1fx" -scale 512x512\! \) -compose over -composite )
  
LAYER_DROPSHADOW=( \( "$DualTabV_shadow" -scale 512x512\! \) -compose over -composite )
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
            LAYER_STAR_IMAGE=( \( "$star_image" -scale 88x84\! -gravity Northwest -geometry +40+404 \( +clone -background BLACK -shadow 0x1.2+4+6 \) +swap -background none -layers merge -extent 512x512 \) -compose Over -composite )
            if [[ -n "$rating" ]]; then
                LAYER_RATING=( \( -font "$APP_DIR/resources/ANGIE-BOLD.TTF" -fill "rgba(0,0,0,0.9)" -density 400 -pointsize 6 -kerning 0 label:"$rating" -gravity Northwest -geometry +52+429 \( +clone -background ORANGE -shadow 30x1.2+2+2 \) +swap -background none -layers merge \( +clone -background YELLOW -shadow 30x1.2-2-2 \) +swap -background none -layers merge \( +clone -background ORANGE -shadow 30x1.2-2+2 \) +swap -background none -layers merge \( +clone -background ORANGE -shadow 30x1.2+2-2 \) +swap -background none -layers merge \) -compose Over -composite )
            fi
        fi
    fi
fi

# LAYER-GENRE
LAYER_GENRE=()
if [[ "$display_movieinfo" == "yes" ]] && [[ "$show_Genre" == "yes" ]] && [[ -n "$genre" ]]; then
    LAYER_GENRE=( \( -font "$APP_DIR/resources/ANGIE-BOLD.TTF" -fill BLACK -density 400 -pointsize 5 -kerning 0 -gravity Northwest -geometry +113+440 label:"$genre" \( +clone -background ORANGE -shadow 70x1.2+2.5+2.5 \) +swap -background none -layers merge \( +clone -background YELLOW -shadow 70x1.2-2.5-2.5 \) +swap -background none -layers merge \( +clone -background ORANGE -shadow 70x1.2-2.5+2.5 \) +swap -background none -layers merge \( +clone -background ORANGE -shadow 70x1.2+2.5-2.5 \) +swap -background none -layers merge \( +clone -background BLACK -shadow 0x0.2+4+5 \) +swap -background none -layers merge \) -composite )
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
        LAYER_LOGO_IMAGE=( \( "$Logo" -trim +repage -scale 167x60^ -background none -gravity center -geometry +200-72 -rotate 90 \) -compose Over -composite )
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
        LAYER_CLEARART_IMAGE=( \( "$ClearArt" -trim +repage -scale 380x -background none -gravity SouthWest -geometry -250-320 \( +clone -background BLACK -shadow 40x40+10+10 \) +swap -background none -layers merge \( +clone -background BLACK -shadow 40x40-10-10 \) +swap -background none -layers merge \( +clone -background BLACK -shadow 40x40-10+10 \) +swap -background none -layers merge \( +clone -background BLACK -shadow 40x40+10-10 \) +swap -background none -layers merge \) -compose Over -composite )
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

    FolNamPos=()
    if [[ ${#foldername} -le $((FolNamShortLimit - 3)) ]]; then
        FolNamPos=( $Foldername_Pos_Short_Left )
    else
        FolNamPos=( $FolderName_Pos_Short_Center )
    fi
    
    if [[ "$FolderName_Center" == "yes" ]]; then FolNamPos=( $FolderName_Pos_Short_Center ); fi
    if [[ "$FolderName_Center" == "no" ]]; then FolNamPos=( $Foldername_Pos_Short_Left ); fi

    LAYER_FOLDER_NAME_SHORT=( \( -font "$APP_DIR/resources/BIG_NOODLE_TITLING.ttf" -fill "$FolderName_Font_Color" -density 400 -pointsize 7 -kerning 1.2 ${FolNamPos[@]} -background none label:"$FolNamShort" \( +clone -background BLACK -shadow 00x2+0.6+0.6 \) +swap -background none -layers merge \( +clone -background BLACK -shadow 00x2-0.6-0.6 \) +swap -background none -layers merge \( +clone -background BLACK -shadow 00x2-0.6+0.6 \) +swap -background none -layers merge \( +clone -background BLACK -shadow 00x2+0.6-0.6 \) +swap -background none -layers merge -rotate 90 \) -composite )

    if [[ ${#foldername} -gt $FolNamShortLimit ]] && [[ "$FolderNameLong_characters_limit" != "0" ]]; then
        LAYER_FOLDER_NAME_LONG=( \( -font "$APP_DIR/resources/BIG_NOODLE_TITLING.ttf" -fill "$FolderName_Font_Color" -density 400 -pointsize 2.8 -kerning 2 $Foldername_Pos_Long -background none label:"$FolNamLong" \( +clone -background BLACK -shadow 0x5+0.2+0.2 \) +swap -background none -layers merge \( +clone -background BLACK -shadow 0x5-0.2-0.2 \) +swap -background none -layers merge \( +clone -background BLACK -shadow 0x5-0.2+0.2 \) +swap -background none -layers merge \( +clone -background BLACK -shadow 0x5+0.2-0.2 \) +swap -background none -layers merge -rotate 90 \) -composite )
    fi
fi

# LAYER-TAB2
LAYER_TAB2=( \( "$inputfile" -resize 3x3\! -resize 1000x1000\! -scale 512x512\! -modulate 100,130 -brightness-contrast 8x13 -brightness-contrast -2x0 -blur 0x50 "$DualTabV_tab2" \) -compose over -composite )
LAYER_TAB2_FX=( \( "$DualTabV_tab2fx" -scale 512x512\! \) -compose over -composite )

LAYER_TAB2_LOGO=()
LAYER_TAB2_LABEL=()
if [[ -n "$tab2_label" ]]; then
    Logo2=""
    for ext in "${ImageSupport[@]}"; do
        if [[ -f "${tab2_label%.*}${ext}" ]]; then
            Logo2="$PWD/${tab2_label%.*}${ext}"
            break
        fi
    done
    
    if [[ -n "$Logo2" ]]; then
        LAYER_TAB2_LOGO=( \( "$Logo2" -trim +repage -scale 150x45^ -background none -gravity center -geometry +205+90 -rotate 90 \) -compose Over -composite )
    else
        len=${#tab2_label}
        if [[ $len -gt 11 ]]; then
            refLen=9
            baseFont=45
            baseKerning=40
            stepFont=$(( (50-45)/(15-11) ))
            stepKerning=$(( (30-10)/(15-11) ))
            
            Tab2fontsize=$(( baseFont - (len - refLen) * stepFont ))
            Tab2kerning=$(( baseKerning - (len - refLen) * stepKerning ))
            
            if [[ $Tab2fontsize -ge 10 ]]; then
                Tab2_FontSize="${Tab2fontsize:0:${#Tab2fontsize}-1}.${Tab2fontsize: -1}"
            fi
            if [[ $Tab2kerning -ge 10 ]]; then
                Tab2_FontSpacing="${Tab2kerning:0:${#Tab2kerning}-1}.${Tab2kerning: -1}"
            fi
            if [[ $len -gt 15 ]]; then
                Tab2_FontSpacing=0
            fi
        fi
        
        LAYER_TAB2_LABEL=( \( -font "$APP_DIR/resources/BIG_NOODLE_TITLING.ttf" -fill "$FolderName_Font_Color" -density 400 -pointsize "$Tab2_FontSize" -kerning "$Tab2_FontSpacing" -gravity center -geometry +207+88 -background none label:"$tab2_label" \( +clone -background BLACK -shadow ${Tab2_Shadow}+1+1 \) +swap -background none -layers merge \( +clone -background BLACK -shadow ${Tab2_Shadow}+1+1 \) +swap -background none -layers merge \( +clone -background BLACK -shadow ${Tab2_Shadow}+1+1 \) +swap -background none -layers merge \( +clone -background BLACK -shadow ${Tab2_Shadow}+1+1 \) +swap -background none -layers merge -rotate 90 \) -composite )
    fi
fi

shopt -u nocasematch

"$IM_CMD" \
  "${LAYER_BACKGROUND[@]}" \
  "${LAYER_TAB2[@]}" \
  "${LAYER_TAB2_LABEL[@]}" \
  "${LAYER_TAB2_LOGO[@]}" \
  "${LAYER_TAB2_FX[@]}" \
  "${LAYER_TAB1[@]}" \
  "${LAYER_TAB1_FX[@]}" \
  "${LAYER_LOGO_IMAGE[@]}" \
  "${LAYER_FOLDER_NAME_SHORT[@]}" \
  "${LAYER_FOLDER_NAME_LONG[@]}" \
  "${LAYER_POSTER_MAIN[@]}" \
  "${LAYER_CLEARART_IMAGE[@]}" \
  "${LAYER_STAR_IMAGE[@]}" \
  "${LAYER_RATING[@]}" \
  "${LAYER_GENRE[@]}" \
  "${LAYER_ICON_SIZE[@]}" \
  "$OutputFile"

"$IM_CMD" \
  "${LAYER_BACKGROUND[@]}" \
  "${LAYER_DROPSHADOW[@]}" \
  \( "$OutputFile" -scale 512x512\! \) -compose over -composite \
  "${LAYER_ICON_SIZE[@]}" \
  "$OutputFile"
