#!/bin/bash

# RightClick-Folder-Icon-Tools - Color Picker for KDE
# Opens a color selection dialog and outputs rgba string

color_hex=$(kdialog --getcolor)

if [ -n "$color_hex" ]; then
    # kdialog returns color in #RRGGBB format
    # We need to convert it to rgba(R,G,B,0.9)
    # Remove the hash
    hex="${color_hex#\#}"
    r=$((16#${hex:0:2}))
    g=$((16#${hex:2:2}))
    b=$((16#${hex:4:2}))
    
    # Export it for the caller
    export FolderName_Font_Color="rgba($r,$g,$b,0.9)"
else
    # Default fallback
    export FolderName_Font_Color="rgba(255,255,255,0.9)"
fi
