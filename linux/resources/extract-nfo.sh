#!/bin/bash

# RightClick-Folder-Icon-Tools - NFO Extractor
# Parses .nfo files to extract Rating and Genre
# Designed to be sourced by templates (e.g. source extract-nfo.sh "$folder")

TARGET_DIR="${1:-.}"

export rating=""
export genre=""

NFO_FILE=$(find "$TARGET_DIR" -maxdepth 1 -name "*.nfo" | head -n 1)

if [ -n "$NFO_FILE" ] && [ -f "$NFO_FILE" ]; then
    # Extract rating (try imdb, themoviedb, tvdb, or default rating)
    # This is a simple regex extraction suited for standard Kodi/Plex NFOs
    
    # Try finding <rating> block and <value> inside it, or <userrating>
    raw_rating=$(grep -oP '(?<=<rating>).*?(?=</rating>)' "$NFO_FILE" | grep -oP '(?<=<value>).*?(?=</value>)' | head -n 1)
    
    if [ -z "$raw_rating" ]; then
        raw_rating=$(grep -oP '(?<=<userrating>).*?(?=</userrating>)' "$NFO_FILE" | head -n 1)
    fi
    
    if [ -n "$raw_rating" ]; then
        # Take first 3 chars, e.g. "8.5" or "10."
        rating=$(echo "$raw_rating" | cut -c 1-3)
        if [ "$rating" == "10." ]; then
            rating="10"
        fi
    fi
    
    # Extract genres
    # NFOs can have multiple <genre>Action</genre> lines
    genres=$(grep -oP '(?<=<genre>).*?(?=</genre>)' "$NFO_FILE" | sed 's/Science Fiction/SciFi/g')
    
    if [ -n "$genres" ]; then
        # Join with comma and space
        genre=$(echo "$genres" | paste -sd, - | sed 's/,/, /g')
        
        # Enforce length limit (default 22 chars approx like batch)
        if [ ${#genre} -gt 22 ]; then
            genre="${genre:0:19}..."
        fi
    fi
fi

if [ -z "$rating" ]; then
    rating="0.0"
fi
if [ -z "$genre" ]; then
    genre="Unknown"
fi
