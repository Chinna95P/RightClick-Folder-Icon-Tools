#!/bin/bash

# RightClick-Folder-Icon-Tools - Linux Main Script
# Invoked via KDE ServiceMenus

CONFIG_DIR="$HOME/.config/rcfi-tools"
CONFIG_FILE="$CONFIG_DIR/config.ini"
APP_DIR="$HOME/.local/share/rcfi-tools"
TEMPLATES_DIR="$APP_DIR/templates"
RESOURCES_DIR="$APP_DIR/resources"
COLLECTIONS_DIR="$APP_DIR/collections"

IM_CMD="magick"
if ! command -v magick >/dev/null 2>&1; then
    if command -v convert >/dev/null 2>&1; then
        IM_CMD="convert"
    else
        kdialog --error "ImageMagick is not installed. Please run the installer or install ImageMagick."
        exit 1
    fi
fi

# Load config
declare -A CONFIG
if [ -f "$CONFIG_FILE" ]; then
    while IFS='=' read -r key value; do
        # Ignore comments and empty lines, remove brackets
        if [[ "$key" =~ ^\[.*\]$ ]] || [[ -z "$key" ]] || [[ "$key" == \;* ]] || [[ "$key" == \#* ]]; then
            continue
        fi
        CONFIG["$key"]="$value"
    done < "$CONFIG_FILE"
else
    CONFIG["Keywords"]="*"
    CONFIG["Template"]="(none).sh"
    CONFIG["TemplateAlwaysAsk"]="No"
fi

get_config() {
    echo "${CONFIG[$1]}"
}

set_config() {
    local key="$1"
    local val="$2"
    CONFIG["$key"]="$val"
    # Overwrite config file
    echo "[General]" > "$CONFIG_FILE"
    for k in "${!CONFIG[@]}"; do
        echo "$k=${CONFIG[$k]}" >> "$CONFIG_FILE"
    done
}

refresh_dolphin() {
    # Dolphin updates automatically if the .directory file changes.
    # We can also use dbus or simply `touch` the folder.
    local folder="$1"
    touch "$folder"
}

set_folder_icon() {
    local folder="$1"
    local icon_path="$2" # Absolute path to the icon file (should be inside the folder)
    local dir_file="$folder/.directory"
    
    # Write the .directory file
    cat > "$dir_file" << EOF
[Desktop Entry]
Icon=$icon_path
EOF
    refresh_dolphin "$folder"
}

choose_template() {
    # List all .sh files in templates dir
    local options=()
    for t in "$TEMPLATES_DIR"/*.sh; do
        if [ -f "$t" ]; then
            local tname=$(basename "$t")
            options+=("$tname" "$tname")
        fi
    done
    
    local choice=$(kdialog --combobox "Select a template:" "${options[@]}")
    if [ -n "$choice" ]; then
        set_config "Template" "$choice"
        kdialog --msgbox "Template set to: $choice"
    fi
}

change_icon_interactive() {
    local folder="$1"
    
    # Ask for an image file
    local img=$(kdialog --getopenfilename "$folder" "image/*")
    if [ -z "$img" ]; then
        exit 0
    fi
    
    # Generate the icon using the current template
    local template=$(get_config "Template")
    if [[ "$(get_config "TemplateAlwaysAsk")" == "Yes" ]]; then
        choose_template
        template=$(get_config "Template")
    fi
    
    local template_path="$TEMPLATES_DIR/$template"
    local output_icon="$folder/.foldericon.png"
    
    if [ -f "$template_path" ]; then
        # Export variables for the template
        export inputfile="$img"
        export outputfile="$output_icon"
        export IM_CMD
        export APP_DIR
        export TemplateIconSize=$(get_config "TemplateIconSize")
        if [ "$TemplateIconSize" == "Auto" ] || [ -z "$TemplateIconSize" ]; then
            export TemplateIconSize="512x512"
        fi
        
        # Run template
        bash "$template_path"
        
        if [ -f "$output_icon" ]; then
            set_folder_icon "$folder" "./.foldericon.png"
            kdialog --passivepopup "Folder icon changed successfully!" 3
        else
            kdialog --error "Failed to generate icon using template $template"
        fi
    else
        kdialog --error "Template not found: $template_path"
    fi
}

remove_icon() {
    local folder="$1"
    local dir_file="$folder/.directory"
    local icon_file="$folder/.foldericon.png"
    
    if kdialog --warningyesno "Remove folder icon from $(basename "$folder")?"; then
        rm -f "$dir_file"
        rm -f "$icon_file"
        # Also look for any desktop.ini and foldericon.ico from windows version
        rm -f "$folder/desktop.ini"
        rm -f "$folder/foldericon.ico"
        
        refresh_dolphin "$folder"
        kdialog --passivepopup "Folder icon removed." 3
    fi
}

# --- Main Entry Point ---

ACTION="$1"
TARGET="$2"

if [ -z "$ACTION" ]; then
    kdialog --msgbox "RightClick-Folder-Icon-Tools for Linux\nRun via KDE context menus."
    exit 0
fi

case "$ACTION" in
    --change-icon)
        change_icon_interactive "$TARGET"
        ;;
    --choose-template)
        choose_template
        ;;
    --remove)
        remove_icon "$TARGET"
        ;;
    --img-gen-png|--img-gen-icon)
        # Standard flow: process image, prompt where to save or just save alongside
        output="${TARGET%.*}_icon.png"
        export inputfile="$TARGET"
        export outputfile="$output"
        export IM_CMD
        export APP_DIR
        template=$(get_config "Template")
        if [ -f "$TEMPLATES_DIR/$template" ]; then
            bash "$TEMPLATES_DIR/$template"
            kdialog --passivepopup "Icon generated: $output" 3
        else
            kdialog --error "Template not found."
        fi
        ;;
    --search-fi|--search-poster|--search-icon)
        query=$(basename "$TARGET")
        suffix="folder icon"
        [[ "$ACTION" == "--search-poster" ]] && suffix="poster"
        [[ "$ACTION" == "--search-icon" ]] && suffix="icon"
        xdg-open "https://google.com/search?q=${query}+${suffix}&tbm=isch&tbs=ic:trans"
        ;;
    --collections)
        # Open collections folder in file manager so user can pick an image
        # Wait, if called from context menu, usually it opens a dialog to pick from collections
        img=$(kdialog --getopenfilename "$COLLECTIONS_DIR" "image/*")
        if [ -n "$img" ]; then
            # Generate icon using the selected image
            export inputfile="$img"
            export outputfile="$TARGET/.foldericon.png"
            export IM_CMD
            export APP_DIR
            template=$(get_config "Template")
            if [ -f "$TEMPLATES_DIR/$template" ]; then
                bash "$TEMPLATES_DIR/$template"
                set_folder_icon "$TARGET" "./.foldericon.png"
                kdialog --passivepopup "Folder icon changed using collection image!" 3
            fi
        fi
        ;;
    --img-add-col)
        mkdir -p "$COLLECTIONS_DIR"
        cp "$TARGET" "$COLLECTIONS_DIR/"
        kdialog --passivepopup "Added to collections!" 3
        ;;
    --set-as-icon)
        # Assuming TARGET is the image file. We need to ask for the folder.
        folder=$(kdialog --getexistingdirectory "$HOME")
        if [ -n "$folder" ]; then
            export inputfile="$TARGET"
            export outputfile="$folder/.foldericon.png"
            export IM_CMD
            export APP_DIR
            template=$(get_config "Template")
            if [ -f "$TEMPLATES_DIR/$template" ]; then
                bash "$TEMPLATES_DIR/$template"
                set_folder_icon "$folder" "./.foldericon.png"
                kdialog --passivepopup "Set as folder icon for $(basename "$folder")!" 3
            fi
        fi
        ;;
    --img-convert)
        # Basic convert wrapper
        new_ext=$(kdialog --combobox "Select output format:" "png" "jpg" "webp" "bmp")
        if [ -n "$new_ext" ]; then
            out="${TARGET%.*}.$new_ext"
            "$IM_CMD" "$TARGET" "$out"
            kdialog --passivepopup "Converted to $new_ext" 3
        fi
        ;;
    *)
        kdialog --error "Action $ACTION not fully implemented in Linux port yet."
        ;;
esac
