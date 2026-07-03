#!/bin/bash
# custom_foldername.sh for Linux/KDE
# Generates custom_foldername.txt to be sourced by the template.

cfn1="$APP_DIR/linux/resources/custom_foldername.txt"
rm -f "$cfn1"

# Prompt for custom folder name or image
user_input=$(kdialog --title "Custom Folder Name" --inputbox "Enter a folder name or leave empty to skip. \nYou can also select an image logo for the folder name." "")

# If user cancels, exit
if [[ $? -ne 0 ]]; then
    echo "display_FolderName=\"no\"" >> "$cfn1"
    echo "use_Logo_instead_FolderName=\"no\"" >> "$cfn1"
    exit 0
fi

# If empty, skip
if [[ -z "$user_input" || "$user_input" == " " || "$user_input" == "_" ]]; then
    echo "display_FolderName=\"no\"" >> "$cfn1"
    echo "use_Logo_instead_FolderName=\"no\"" >> "$cfn1"
    exit 0
fi

# Check if input is a file path (for logo)
if [[ -f "$user_input" ]]; then
    echo "Logo=\"$user_input\"" >> "$cfn1"
    echo "LogoName=\"$(basename "$user_input")\"" >> "$cfn1"
    echo "use_Logo_instead_FolderName=\"yes\"" >> "$cfn1"
    echo "custom_FolderName_HaveTheLogo=\"yes\"" >> "$cfn1"
    exit 0
fi

# Otherwise it's a custom folder name string
echo "foldername=\"$user_input\"" >> "$cfn1"
echo "display_FolderName=\"yes\"" >> "$cfn1"
echo "use_Logo_instead_FolderName=\"no\"" >> "$cfn1"

# Optionally ask for Font Color using kdialog
color_input=$(kdialog --title "Font Color" --getcolor)
if [[ $? -eq 0 && -n "$color_input" ]]; then
    # kdialog returns color like #RRGGBB
    echo "FolderName_Font_Color=\"$color_input\"" >> "$cfn1"
fi

exit 0
