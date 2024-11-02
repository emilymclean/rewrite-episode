#!/bin/bash

# Function to left-pad numbers as two digits, handling non-octal numbers
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
        
        # Determine the title parsing method based on the option
        if [[ $title_option == "--dash-separated-title" ]]; then
            # Use dash separator by default
            if [[ $base_name =~ [sS][0-9]+[eE][0-9]+\ -\ ([^()]+)\( ]]; then
                title="${BASH_REMATCH[1]}"
                title=$(echo "$title" | sed 's/[[:space:]]*$//')
                new_name="${new_name} - ${title}"
            fi
        elif [[ $title_option == "--dot-separated-title" ]]; then
            # Parse title with dot separator and stop at any digit
            if [[ $base_name =~ [sS][0-9]+[eE][0-9]+\.((\.?[^.0-9]+)+)\.[0-9]+ ]]; then
                title="${BASH_REMATCH[1]}"
                echo "$title"
                title=$(echo "$title" | sed 's/\./ /')
                new_name="${new_name} - ${title}"
            fi
        fi
        
        # Get file extension
        extension="${file##*.}"
        
        # Rename file within its directory
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
    echo "Usage: $0 <file_or_directory> [--dash-separated-title | --dot-separated-title] --dry_run"
    exit 1
fi
