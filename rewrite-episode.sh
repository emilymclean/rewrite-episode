#!/bin/bash

# Function to left-pad numbers as two digits, handling non-octal numbers
pad() {
    printf "%02d" "$((10#$1))"
}

# Function to rename files
rename_file() {
    local file="$1"
    local title_option="$2"
    local dry_run="$3"
    
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
                title=$(echo "$title" | sed 's/\./ /g')
                new_name="${new_name} - ${title}"
            fi
        fi
        
        # Get file extension
        extension="${file##*.}"
        
        # If dry_run is set, print what would be done instead of renaming
        if [[ $dry_run == true ]]; then
            echo "DRY RUN: Would rename '$base_name' to '${new_name}.${extension}'"
        else
            # Rename file within its directory
            mv "$file" "${dir}/${new_name}.${extension}"
            echo "Renamed '$base_name' to '${new_name}.${extension}'"
        fi
    else
        echo "No season/episode pattern found in '$file'"
    fi
}

# Check if a directory or file is provided
dry_run=false
title_option=""

# Ensure at least one argument is passed
if [[ "$#" -lt 1 ]]; then
    echo "Usage: $0 <file_or_directory> [--dash-separated-title | --dot-separated-title] [--dry-run]"
    exit 1
fi

# Capture the first argument as the file or directory
file_or_directory="$1"
shift  # Shift the arguments to handle optional parameters

# Process any remaining arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --dry-run) dry_run=true ;;
        --dash-separated-title | --dot-separated-title) title_option="$1" ;;
        *) echo "Unknown option: $1" ; exit 1 ;;
    esac
    shift
done

if [[ -d "$file_or_directory" ]]; then
    for file in "$file_or_directory"/*; do
        rename_file "$file" "$title_option" "$dry_run"
    done
elif [[ -f "$file_or_directory" ]]; then
    rename_file "$file_or_directory" "$title_option" "$dry_run"
else
    echo "Usage: $0 <file_or_directory> [--dash-separated-title | --dot-separated-title] [--dry-run]"
    exit 1
fi