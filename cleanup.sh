#!/bin/bash

# Cleanup script to remove files except specified ones
# Keep: archive-project.sh, cleanup.sh, cursor.md, title.md

echo "Starting cleanup process..."

# Get all files in the current directory
all_files=($(find . -maxdepth 1 -type f -printf "%f\n" 2>/dev/null || find . -maxdepth 1 -type f -exec basename {} \;))

# Define files to keep
files_to_keep=(
    "archive-project.sh"
    "cleanup.sh"
    "cursor.md"
    "title.md"
)

# Counter for removed files
removed_count=0

for file in "${all_files[@]}"; do
    if [[ ! " ${files_to_keep[@]} " =~ " ${file} " ]]; then
        if rm -f "$file" 2>/dev/null; then
            echo "Removed: $file"
            ((removed_count++))
        else
            echo "Error removing $file"
        fi
    else
        echo "Keeping: $file"
    fi
done

echo ""
echo "Cleanup completed!"
echo "Files removed: $removed_count"
echo "Files remaining: ${#files_to_keep[@]}"

# Show remaining files
echo ""
echo "Remaining files:"
for file in "${files_to_keep[@]}"; do
    if [[ -f "$file" ]]; then
        echo "  - $file"
    fi
done
