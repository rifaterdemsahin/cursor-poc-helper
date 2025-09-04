#!/bin/bash

# Cleanup script to remove files except specified ones
# Keep: archive-project.ps1, archive-project.sh, cleanup.ps1, cleanup.sh, cursor.md

echo "Starting cleanup process..."

# Define files to keep
FILES_TO_KEEP=(
    "archive-project.ps1"
    "archive-project.sh"
    "cleanup.ps1"
    "cleanup.sh"
    "cursor.md"
)

# Counter for removed files
REMOVED_COUNT=0

# Get all files in the current directory
for file in *; do
    if [[ -f "$file" ]]; then
        # Check if file should be kept
        KEEP_FILE=false
        for keep in "${FILES_TO_KEEP[@]}"; do
            if [[ "$file" == "$keep" ]]; then
                KEEP_FILE=true
                break
            fi
        done
        
        if [[ "$KEEP_FILE" == false ]]; then
            rm -f "$file"
            echo "Removed: $file"
            ((REMOVED_COUNT++))
        else
            echo "Keeping: $file"
        fi
    fi
done

echo ""
echo "Cleanup completed!"
echo "Files removed: $REMOVED_COUNT"
echo "Files remaining: ${#FILES_TO_KEEP[@]}"

# Show remaining files
echo ""
echo "Remaining files:"
for file in *; do
    if [[ -f "$file" ]]; then
        echo "  - $file"
    fi
done

echo "Cleanup script executed successfully!"
