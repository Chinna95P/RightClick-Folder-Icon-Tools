#!/bin/bash

# RightClick-Folder-Icon-Tools Installer for Linux (KDE)
# Supports Bazzite and other KDE Plasma environments

set -e

echo "=================================================="
echo " RightClick-Folder-Icon-Tools Installer for KDE"
echo "=================================================="
echo ""

# 1. Check dependencies
echo "Checking dependencies..."
MISSING_DEPS=0

# Check for ImageMagick
if command -v magick >/dev/null 2>&1; then
    IM_CMD="magick"
    echo " [OK] ImageMagick (magick) found."
elif command -v convert >/dev/null 2>&1; then
    IM_CMD="convert"
    echo " [OK] ImageMagick (convert) found."
else
    echo " [ERROR] ImageMagick is missing."
    MISSING_DEPS=1
fi

# Check for kdialog
if command -v kdialog >/dev/null 2>&1; then
    echo " [OK] kdialog found."
else
    echo " [ERROR] kdialog is missing."
    MISSING_DEPS=1
fi

if [ $MISSING_DEPS -ne 0 ]; then
    echo ""
    echo "ERROR: Missing required dependencies."
    echo "Please install them before continuing."
    echo ""
    echo "If you are on Bazzite or another immutable Fedora atomic system:"
    echo "  rpm-ostree install ImageMagick kdialog"
    echo "  systemctl reboot"
    echo ""
    echo "On standard Fedora:"
    echo "  sudo dnf install ImageMagick kdialog"
    echo ""
    echo "On Ubuntu/Debian:"
    echo "  sudo apt install imagemagick kdialog"
    exit 1
fi

# 2. Setup directories
DEST_DIR="$HOME/.local/share/rcfi-tools"
CONFIG_DIR="$HOME/.config/rcfi-tools"

# In KDE Plasma 6, servicemenus go to kio/servicemenus
# In KDE Plasma 5, they go to kservices5/ServiceMenus
PLASMA_VER=$(plasmashell --version 2>/dev/null | awk '{print $2}' | cut -d. -f1)
if [ "$PLASMA_VER" == "6" ]; then
    MENU_DIR="$HOME/.local/share/kio/servicemenus"
else
    MENU_DIR="$HOME/.local/share/kservices5/ServiceMenus"
    # Fallback to kio/servicemenus if kservices5 doesn't exist
    if [ ! -d "$MENU_DIR" ]; then
        MENU_DIR="$HOME/.local/share/kio/servicemenus"
    fi
fi

echo "Setting up directories..."
mkdir -p "$DEST_DIR"
mkdir -p "$CONFIG_DIR"
mkdir -p "$MENU_DIR"

# 3. Copy files
echo "Copying files to $DEST_DIR..."
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"

# Copy core script
cp "$SCRIPT_DIR/rcfi-tools.sh" "$DEST_DIR/"
chmod +x "$DEST_DIR/rcfi-tools.sh"

# Copy resources and templates
cp -r "$SCRIPT_DIR/resources" "$DEST_DIR/"
cp -r "$SCRIPT_DIR/templates" "$DEST_DIR/"
# Also copy images and collections from the root if they exist
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
if [ -d "$ROOT_DIR/images" ]; then
    cp -r "$ROOT_DIR/images" "$DEST_DIR/"
fi
if [ -d "$ROOT_DIR/collections" ]; then
    cp -r "$ROOT_DIR/collections" "$DEST_DIR/"
fi

# Ensure resource scripts are executable
chmod +x "$DEST_DIR/resources/"*.sh

# 4. Install ServiceMenus
echo "Installing KDE ServiceMenus to $MENU_DIR..."
# We will use sed to dynamically replace the Exec path in the .desktop files
for desktop_file in "$SCRIPT_DIR/resources/servicemenus/"*.desktop; do
    if [ -f "$desktop_file" ]; then
        filename=$(basename "$desktop_file")
        sed "s|Exec=rcfi-tools.sh|Exec=$DEST_DIR/rcfi-tools.sh|g" "$desktop_file" > "$MENU_DIR/$filename"
        chmod +x "$MENU_DIR/$filename"
    fi
done

# 5. Initialize default config
if [ ! -f "$CONFIG_DIR/config.ini" ]; then
    echo "Creating default configuration..."
    cat > "$CONFIG_DIR/config.ini" << EOF
[General]
Keywords=*
Template=(none)
TemplateAlwaysAsk=No
TemplateIconSize=Auto
HideAsSystemFiles=Yes
DeleteOriginalFile=No
TextEditor=kwrite
CollectionsFolder=$DEST_DIR/collections
EOF
fi

echo ""
echo "=================================================="
echo " Installation Complete!"
echo "=================================================="
echo "RightClick-Folder-Icon-Tools is now available in Dolphin."
echo "If the context menus do not appear immediately, you may need to restart Dolphin:"
echo "  killall dolphin"
echo ""
