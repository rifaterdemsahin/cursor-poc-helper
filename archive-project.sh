#!/bin/bash

# Enhanced Project Archive Script for WSL/Linux Environment
# This script reads the project title from cursor.md and uses it for consistent archiving
# Automatically detects environment and uses appropriate archive location

echo "=== Enhanced Project Archive Script (WSL/Linux) ==="
echo "Detecting environment and setting archive location..."

# Detect environment and set appropriate archive location
COMPUTER_NAME=$(hostname)
USER_NAME=$(whoami)
OS_TYPE=$(uname -s)
IS_WSL=false

# Check if running in WSL
if [[ -n "$WSL_DISTRO_NAME" ]] || [[ -n "$WSLENV" ]] || grep -q Microsoft /proc/version 2>/dev/null; then
    IS_WSL=true
fi

echo "Computer Name: $COMPUTER_NAME"
echo "User Name: $USER_NAME"
echo "OS Type: $OS_TYPE"
echo "WSL Environment: $IS_WSL"

# Determine environment and archive location
if [[ "$IS_WSL" == true ]] && [[ "$COMPUTER_NAME" == *"XPS"* ]] || [[ "$COMPUTER_NAME" == *"xps"* ]] || [[ "$COMPUTER_NAME" == *"LaptopErdem"* ]] || [[ "$COMPUTER_NAME" == *"laptoperdem"* ]]; then
    # Dell XPS running WSL2
    ENVIRONMENT="xps"
    ARCHIVE_BASE_PATH="/mnt/c/projects/secondbrain/secondbrain/4_Archieve/$(date +%Y/%m/%d)"
    echo "Detected Dell XPS with WSL2 environment - using /mnt/c/projects/secondbrain/secondbrain/4_Archieve"
elif [[ "$COMPUTER_NAME" == *"3995wrx"* ]] || [[ "$COMPUTER_NAME" == *"3995WRX"* ]]; then
    # Workstation environment
    ENVIRONMENT="workstation"
    ARCHIVE_BASE_PATH="/mnt/f/secondbrain_v4/secondbrain/secondbrain/4_Archieve/$(date +%Y/%m/%d)"
    echo "Detected 3995wrx workstation - using /mnt/f drive"
elif [[ "$OS_TYPE" == "Darwin" ]]; then
    # Mac environment
    ENVIRONMENT="mac"
    ARCHIVE_BASE_PATH="$HOME/projects/secondbrain/$(date +%Y/%m/%d)"
    echo "Detected Mac environment - using ~/projects/secondbrain"
elif [[ "$COMPUTER_NAME" == *"XPS"* ]] || [[ "$COMPUTER_NAME" == *"xps"* ]] || [[ "$COMPUTER_NAME" == *"LaptopErdem"* ]] || [[ "$COMPUTER_NAME" == *"laptoperdem"* ]]; then
    # Dell XPS native Linux
    ENVIRONMENT="xps"
    ARCHIVE_BASE_PATH="/mnt/c/projects/secondbrain/secondbrain/4_Archieve/$(date +%Y/%m/%d)"
    echo "Detected Dell XPS native Linux - using /mnt/c/projects/secondbrain/secondbrain/4_Archieve"
else
    # Fallback for unknown environments
    ENVIRONMENT="unknown"
    ARCHIVE_BASE_PATH="/mnt/c/projects/secondbrain/secondbrain/4_Archieve/$(date +%Y/%m/%d)"
    echo "Unknown environment - using default /mnt/c/projects/secondbrain/secondbrain/4_Archieve"
fi

# Location verification
echo "Environment detected: $ENVIRONMENT"
if [[ "$ENVIRONMENT" == "xps" ]] && [[ "$IS_WSL" == true ]]; then
    echo "✓ Confirmed: Running on Dell XPS in WSL2 environment"
    echo "✓ Destination: /mnt/c/projects/secondbrain/secondbrain/4_Archieve"
elif [[ "$ENVIRONMENT" == "xps" ]]; then
    echo "✓ Confirmed: Running on Dell XPS native Linux environment"
    echo "✓ Destination: /mnt/c/projects/secondbrain/secondbrain/4_Archieve"
elif [[ "$ENVIRONMENT" == "workstation" ]]; then
    echo "✓ Confirmed: Running on workstation environment"
    echo "✓ Destination: /mnt/f/secondbrain_v4/secondbrain/secondbrain/4_Archieve"
elif [[ "$ENVIRONMENT" == "mac" ]]; then
    echo "✓ Confirmed: Running on Mac environment"
    echo "✓ Destination: ~/projects/secondbrain"
else
    echo "⚠ Warning: Environment not fully recognized"
fi

echo "Reading project title from cursor.md..."

# Read cursor.md to extract project title
if [[ ! -f "cursor.md" ]]; then
    echo "ERROR: cursor.md not found! Cannot proceed without project title."
    exit 1
fi

# Extract title from cursor.md (look for # Project Title or similar)
PROJECT_TITLE=$(grep -m 1 "^# " cursor.md | sed 's/^# *//' | tr -d '\r\n')
if [[ -z "$PROJECT_TITLE" ]]; then
    # Fallback: use directory name
    PROJECT_TITLE=$(basename "$(pwd)")
    echo "No title found in cursor.md, using directory name: $PROJECT_TITLE"
else
    echo "Found project title: $PROJECT_TITLE"
fi

# Create consistent archive location using project title
ARCHIVE_PATH="$ARCHIVE_BASE_PATH/$PROJECT_TITLE"

echo "Starting archival process for: $PROJECT_TITLE"
echo "Archive location: $ARCHIVE_PATH"
echo "Workstation: $COMPUTER_NAME"

# Create archive directory if it doesn't exist
mkdir -p "$ARCHIVE_PATH"

# Get current directory name for project identification
PROJECT_NAME=$(basename "$(pwd)")
CURRENT_DATE=$(date '+%Y-%m-%d %H:%M:%S')

# Get all files in current directory, excluding the script, cursor.md, cleanup.sh, and report files
SOURCE_FILES=($(find . -maxdepth 1 -type f ! -name "archive-project.sh" ! -name "cursor.md" ! -name "cleanup.sh" ! -name "ARCHIVE_SCRIPT_DEVELOPMENT_REPORT.md" ! -name "PROJECT_COMPLETION_REPORT.md" -printf "%f\n" 2>/dev/null || find . -maxdepth 1 -type f ! -name "archive-project.sh" ! -name "cursor.md" ! -name "cleanup.sh" ! -name "ARCHIVE_SCRIPT_DEVELOPMENT_REPORT.md" ! -name "PROJECT_COMPLETION_REPORT.md" -exec basename {} \;))

echo "Found ${#SOURCE_FILES[@]} files to archive"

# Archive each file
ARCHIVED_FILES=()
for file in "${SOURCE_FILES[@]}"; do
    if [[ -f "$file" ]]; then
        destination="$ARCHIVE_PATH/$file"
        echo "Archiving: $file -> $destination"
        
        cp "$file" "$destination"
        ARCHIVED_FILES+=("$file")
        echo "Successfully archived: $file"
    fi
done

# Create enhanced archive summary file with project title
SUMMARY_PATH="$ARCHIVE_PATH/ARCHIVE_SUMMARY.md"
cat > "$SUMMARY_PATH" << EOF
# Project Archive Summary: $PROJECT_TITLE

## Archive Information
- **Project Title**: $PROJECT_TITLE
- **Project Name**: $PROJECT_NAME
- **Archive Date**: $CURRENT_DATE
- **Archive Location**: $ARCHIVE_PATH
- **Environment**: $ENVIRONMENT
- **Computer Name**: $COMPUTER_NAME
- **WSL Environment**: $IS_WSL
- **Archive Base Path**: $ARCHIVE_BASE_PATH
- **Total Files**: ${#ARCHIVED_FILES[@]}
- **Script Used**: Enhanced archive-project.sh

## Project Overview
This archive contains the complete project: **$PROJECT_TITLE**

## Archived Files
EOF

for file in "${ARCHIVED_FILES[@]}"; do
    echo "- $file" >> "$SUMMARY_PATH"
done

cat >> "$SUMMARY_PATH" << EOF

## Original Location
- **Workspace**: $(pwd)
- **Archive Index**: cursor.md (remains in workspace)
- **Project Title Source**: cursor.md

## Archive Benefits
- **Consistent Location**: Always archives to the same base path
- **Title-Based Organization**: Uses project title from cursor.md
- **Date Organization**: Organized by year/month/day
- **Complete Documentation**: Includes all project files and metadata

## Usage
Review the archived files to understand the project structure and functionality.
The project title '$PROJECT_TITLE' ensures consistent organization across archives.

---
*Archived by Enhanced Bash script: archive-project.sh*
*Project title extracted from: cursor.md*
EOF

echo "Created enhanced archive summary: ARCHIVE_SUMMARY.md"

# Create a title-based README for the archive
README_PATH="$ARCHIVE_PATH/README.md"
cat > "$README_PATH" << EOF
# $PROJECT_TITLE

## Project Description
This archive contains the complete project: **$PROJECT_TITLE**

## Archive Contents
- **Source Files**: ${#ARCHIVED_FILES[@]} total files
- **Documentation**: Comprehensive project documentation
- **Archive Summary**: Complete metadata and file listing

## Quick Start
1. Review ARCHIVE_SUMMARY.md for complete file listing
2. Check individual files for specific functionality
3. Refer to cursor.md in the original workspace for context

## Archive Details
- **Archive Date**: $CURRENT_DATE
- **Original Project**: $PROJECT_NAME
- **Archive Location**: $ARCHIVE_PATH

---
*This README was automatically generated by archive-project.sh*
EOF

echo "Created project README: README.md"

# Display enhanced archive results
echo "=== Enhanced Archive Summary ==="
echo "Workstation: $COMPUTER_NAME"
echo "Project Title: $PROJECT_TITLE"
echo "Project Name: $PROJECT_NAME"
echo "Archive Location: $ARCHIVE_PATH"
echo "Archive Base Path: $ARCHIVE_BASE_PATH"
echo "Files Archived: ${#ARCHIVED_FILES[@]}/${#SOURCE_FILES[@]}"
echo "Archive Summary: ARCHIVE_SUMMARY.md"
echo "Project README: README.md"

if [[ ${#ARCHIVED_FILES[@]} -eq ${#SOURCE_FILES[@]} ]]; then
    echo "All files successfully archived!"
    echo "Project '$PROJECT_TITLE' has been moved to the second brain archive."
    echo "cursor.md and archive-project.sh remain in the workspace."
    echo "Archive uses consistent location based on project title from cursor.md"
else
    echo "Some files failed to archive. Check the output above."
fi

echo "Enhanced archive process completed!"
echo "Project title '$PROJECT_TITLE' ensures consistent organization."

# Create a related title file for this archive
TITLE_FILENAME="title_$(date +%Y%m%d_%H%M%S).md"
cat > "$TITLE_FILENAME" << EOF
# Archive Title: $PROJECT_TITLE

## Archive Information
- **Project Title**: $PROJECT_TITLE
- **Archive Date**: $CURRENT_DATE
- **Archive Location**: $ARCHIVE_PATH
- **Environment**: $ENVIRONMENT
- **Computer Name**: $COMPUTER_NAME
- **Files Archived**: ${#ARCHIVED_FILES[@]}

## Related Archive
This title file was created for the archive: **$PROJECT_TITLE**
Archived on: $CURRENT_DATE
Location: $ARCHIVE_PATH

---
*Generated by archive-project.sh*
EOF

echo "Created related title file: $TITLE_FILENAME"

# Execute cleanup script if it exists
if [[ -f "cleanup.sh" ]]; then
    echo "Executing cleanup script..."
    if bash cleanup.sh; then
        echo "Cleanup script executed successfully!"
    else
        echo "Error executing cleanup script"
    fi
else
    echo "No cleanup script found (cleanup.sh)"
fi

echo "Enhanced archive process completed!"
echo "Project title '$PROJECT_TITLE' ensures consistent organization."
