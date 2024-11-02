#!/bin/bash

# Function to left-pad numbers
pad() {
    printf "%02d" "$((10#$1))"
}

# Function to rename files
rename_file() {
    local file="$1"
    local title_option="$2"

    # Extract the directory and filename
    local dir
    dir=$(dirname "$file")
    local base_name
    base_name=$(basename "$file")
    
    # Extract season and episode number (supports S01E01, S1E1, etc.)
    if [[ $base_name =~ ([Ss]([0-9]+))[Ee]([0-9]+) ]]; then
        season=$(pad "${BASH_REMATCH[2]}")
        episode=$(pad "${BASH_REMATCH[3]}")
        new_name="S${season}E${episode}"
        
        # If title option is passed, attempt to extract the title
        if [[ $title_option == "--title" ]]; then
            if [[ $base_name =~ [sS][0-9]+[eE][0-9]+\ -\ ([^()]+)\( ]]; then
                title="${BASH_REMATCH[1]}"
                title=$(echo "$title" | sed 's/[[:space:]]*$//')
                new_name="${new_name} - ${title}"
            fi
        fi
        
        # Get file extension
        extension="${file##*.}"
        
        
        # Rename file
        mv "$file" "${dir}/${new_name}.${extension}"
        echo "Renamed '$base_name' to '${new_name}.${extension}'"
    else
        echo "No season/episode pattern found in '$file'"
    fi
}

# Check if a directory or file is provided
if [[ -d "$1" ]]; then
    for file in "$1"/*; do
        rename_file "$file" "$2"
    done
elif [[ -f "$1" ]]; then
    rename_file "$1" "$2"
else
    echo "Usage: $0 <file_or_directory> [--title]"
    exit 1
fi
