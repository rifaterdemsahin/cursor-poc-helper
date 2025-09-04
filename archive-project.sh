#!/bin/bash

# Enhanced Project Archive Script with MANDATORY Folder Name Parameter
# MCP INTEGRATION: This script REQUIRES MCP to provide the folder name parameter
# MCP MUST pass the ProjectTitle parameter - NO FALLBACK TO cursor.md OR DIRECTORY NAME
# Automatically detects environment (mac, workstation, xps) and uses appropriate archive location
# Usage: ./archive-project.sh "Your Project Name"
# MCP COMMAND EXAMPLE: run archive-project.sh "My Project Name"

# MCP INTEGRATION: Validate that PROJECT_TITLE parameter is provided
PROJECT_TITLE="$1"

# MCP INTEGRATION: Check if project title is provided (MANDATORY)
if [[ -z "$PROJECT_TITLE" ]]; then
    echo "ERROR: MCP MUST provide the project folder name as the first parameter!"
    echo "Usage: $0 \"Your Project Name\""
    echo "MCP COMMAND EXAMPLE: run archive-project.sh \"My Project Name\""
    exit 1
fi

echo "=== Enhanced Project Archive Script ==="
echo "Detecting environment and setting archive location..."

# Detect environment and set appropriate archive location
COMPUTER_NAME=$(hostname)
USER_NAME=$(whoami)
OS=$(uname -s)
IS_WSL=false

# Check if running in WSL
if [[ -n "$WSL_DISTRO_NAME" ]]; then
    IS_WSL=true
fi

echo "Computer Name: $COMPUTER_NAME"
echo "User Name: $USER_NAME"
echo "OS: $OS"
echo "WSL Environment: $IS_WSL"

# Determine environment and archive location
if [[ "$IS_WSL" == true && ("$COMPUTER_NAME" == *"XPS"* || "$COMPUTER_NAME" == *"xps"* || "$COMPUTER_NAME" == *"LaptopErdem"* || "$COMPUTER_NAME" == *"laptoperdem"*) ]]; then
    # Dell XPS running WSL2
    ENVIRONMENT="xps"
    ARCHIVE_BASE_PATH="/mnt/c/projects/secondbrain/secondbrain/4_Archieve/$(date +%Y/%m/%d)"
    echo "Detected Dell XPS with WSL2 environment - using /mnt/c/projects/secondbrain/secondbrain/4_Archieve"
elif [[ "$COMPUTER_NAME" == *"3995wrx"* || "$COMPUTER_NAME" == *"3995WRX"* ]]; then
    # Workstation environment
    ENVIRONMENT="workstation"
    ARCHIVE_BASE_PATH="/mnt/f/secondbrain_v4/secondbrain/secondbrain/4_Archieve/$(date +%Y/%m/%d)"
    echo "Detected 3995wrx workstation - using /mnt/f drive"
elif [[ "$OS" == "Darwin" ]]; then
    # Mac environment
    ENVIRONMENT="mac"
    ARCHIVE_BASE_PATH="$HOME/projects/secondbrain/$(date +%Y/%m/%d)"
    echo "Detected Mac environment - using ~/projects/secondbrain"
elif [[ "$COMPUTER_NAME" == *"XPS"* || "$COMPUTER_NAME" == *"xps"* || "$COMPUTER_NAME" == *"LaptopErdem"* || "$COMPUTER_NAME" == *"laptoperdem"* ]]; then
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
if [[ "$ENVIRONMENT" == "xps" && "$IS_WSL" == true ]]; then
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

# MCP INTEGRATION: Project title is MANDATORY and MUST be provided by MCP
# NO FALLBACK LOGIC - MCP is responsible for providing the correct folder name
echo "Using MCP-provided project title: $PROJECT_TITLE"

# Create consistent archive location using project title
ARCHIVE_PATH="$ARCHIVE_BASE_PATH/$PROJECT_TITLE"

echo "Starting archival process for: $PROJECT_TITLE"
echo "Archive location: $ARCHIVE_PATH"
echo "Workstation: $COMPUTER_NAME"

# Create archive directory if it doesn't exist
mkdir -p "$ARCHIVE_PATH"

# Get current directory name for project identification
PROJECT_NAME=$(basename "$PWD")
CURRENT_DATE=$(date '+%Y-%m-%d %H:%M:%S')

# Define files to exclude from archive (keep in workspace)
EXCLUDE_FILES=(
    "archive-project.ps1"
    "archive-project.sh"
    "cleanup.ps1"
    "cleanup.sh"
    "cursor.md"
)

# Create exclude pattern for find command
EXCLUDE_PATTERN=""
for file in "${EXCLUDE_FILES[@]}"; do
    if [[ -n "$EXCLUDE_PATTERN" ]]; then
        EXCLUDE_PATTERN="$EXCLUDE_PATTERN -o"
    fi
    EXCLUDE_PATTERN="$EXCLUDE_PATTERN -name '$file'"
done

# Copy files to archive (excluding specified files)
echo "Copying project files to archive..."
FILES_COPIED=0
TOTAL_FILES=0

# Count total files first
TOTAL_FILES=$(find . -maxdepth 1 -type f | wc -l)

# Copy files excluding the ones we want to keep
for file in *; do
    if [[ -f "$file" ]]; then
        # Check if file should be excluded
        EXCLUDE_FILE=false
        for exclude in "${EXCLUDE_FILES[@]}"; do
            if [[ "$file" == "$exclude" ]]; then
                EXCLUDE_FILE=true
                break
            fi
        done
        
        if [[ "$EXCLUDE_FILE" == false ]]; then
            cp "$file" "$ARCHIVE_PATH/"
            echo "Copied: $file"
            ((FILES_COPIED++))
        else
            echo "Excluded: $file"
        fi
    fi
done

# Create enhanced archive summary
SUMMARY_PATH="$ARCHIVE_PATH/ARCHIVE_SUMMARY.md"
cat > "$SUMMARY_PATH" << EOF
# Archive Summary

**Project**: $PROJECT_TITLE  
**Project Name**: $PROJECT_NAME  
**Archive Date**: $CURRENT_DATE  
**Workstation**: $COMPUTER_NAME  
**Environment**: $ENVIRONMENT  
**Archive Location**: $ARCHIVE_PATH  

## Files Archived
- **Total Files**: $FILES_COPIED
- **Archive Date**: $(date '+%Y-%m-%d %H:%M:%S')
- **Source Directory**: $PWD

## Excluded Files (Kept in Workspace)
$(printf '- %s\n' "${EXCLUDE_FILES[@]}")

## Archive Contents
$(ls -la "$ARCHIVE_PATH" | grep -v "^total" | awk '{print "- " $9 " (" $5 " bytes)"}')

---
*This archive was created using the enhanced archive script with MCP-provided project title.*
EOF

echo "Created enhanced archive summary: ARCHIVE_SUMMARY.md"

# Create project README
README_PATH="$ARCHIVE_PATH/README.md"
cat > "$README_PATH" << EOF
# $PROJECT_TITLE

**Archived**: $CURRENT_DATE  
**Source**: $PWD  
**Workstation**: $COMPUTER_NAME  

## Project Overview
This archive contains the complete project files for $PROJECT_TITLE.

## Archive Contents
- Source code and project files
- Technical documentation
- Archive summary and metadata

## Usage
Refer to the individual files in this archive for specific usage instructions.

---
*Archived using enhanced archive script with MCP-provided project title.*
EOF

echo "Created project README: README.md"

# Display summary
echo ""
echo "=== Enhanced Archive Summary ==="
echo "Workstation: $COMPUTER_NAME"
echo "Project Title: $PROJECT_TITLE"
echo "Project Name: $PROJECT_NAME"
echo "Archive Location: $ARCHIVE_PATH"
echo ""
echo "Archive Base Path: $ARCHIVE_BASE_PATH"
echo "Files Archived: $FILES_COPIED/$TOTAL_FILES"
echo "Archive Summary: ARCHIVE_SUMMARY.md"
echo "Project README: README.md"

if [[ $FILES_COPIED -gt 0 ]]; then
    echo "All files successfully archived!"
    echo "Project '$PROJECT_TITLE' has been moved to the second brain archive."
    echo "cursor.md and archive scripts remain in the workspace."
    echo "Archive uses consistent location based on MCP-provided project title"
    echo "Enhanced archive process completed!"
    echo "MCP-provided project title '$PROJECT_TITLE' ensures consistent organization."
    
    # Create related title file
    TITLE_FILE="title_$(date +%Y%m%d_%H%M%S).md"
    cat > "$TITLE_FILE" << EOF
# Project Title Reference

**Project**: $PROJECT_TITLE  
**Date**: $CURRENT_DATE  
**Archive Location**: $ARCHIVE_PATH  

This file was created during the archive process to maintain project title consistency.
EOF
    echo "Created related title file: $TITLE_FILE"
    
    # Execute cleanup script
    echo "Executing cleanup script..."
    if [[ -f "cleanup.sh" ]]; then
        bash cleanup.sh
    else
        echo "Cleanup script not found, skipping cleanup."
    fi
    
    echo "Enhanced archive process completed!"
    echo "MCP-provided project title '$PROJECT_TITLE' ensures consistent organization."
else
    echo "No files were archived. Check file permissions and paths."
    exit 1
fi
