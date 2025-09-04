# Enhanced Project Archive Script with Title from cursor.md
# This script reads the project title from cursor.md and uses it for consistent archiving
# Automatically detects environment (mac, workstation, xps) and uses appropriate archive location
# Usage: .\archive-project.ps1 [ProjectTitle]
# If ProjectTitle is not provided, it will be extracted from cursor.md or use directory name

param(
    [Parameter(Mandatory=$false)]
    [string]$ProjectTitle
)

Write-Host "=== Enhanced Project Archive Script ===" -ForegroundColor Green
Write-Host "Detecting environment and setting archive location..." -ForegroundColor Yellow

# Detect environment and set appropriate archive location
$ComputerName = $env:COMPUTERNAME
$UserName = $env:USERNAME
$OS = $env:OS
$IsWSL = $null -ne $env:WSL_DISTRO_NAME

Write-Host "Computer Name: $ComputerName" -ForegroundColor Cyan
Write-Host "User Name: $UserName" -ForegroundColor Cyan
Write-Host "OS: $OS" -ForegroundColor Cyan
Write-Host "WSL Environment: $IsWSL" -ForegroundColor Cyan

# Determine environment and archive location
if ($IsWSL -and ($ComputerName -like "*XPS*" -or $ComputerName -like "*xps*" -or $ComputerName -like "*LaptopErdem*" -or $ComputerName -like "*laptoperdem*")) {
    # Dell XPS running WSL2
    $Environment = "xps"
    $ArchiveBasePath = "C:\projects\secondbrain\secondbrain\4_Archieve\$(Get-Date -Format 'yyyy\/MM\/dd')"
    Write-Host "Detected Dell XPS with WSL2 environment - using C:\projects\secondbrain\secondbrain\4_Archieve" -ForegroundColor Green
} elseif ($ComputerName -like "*3995wrx*" -or $ComputerName -like "*3995WRX*") {
    # Workstation environment
    $Environment = "workstation"
    $ArchiveBasePath = "F:\secondbrain_v4\secondbrain\secondbrain\4_Archieve\$(Get-Date -Format 'yyyy\/MM\/dd')"
    Write-Host "Detected 3995wrx workstation - using F: drive" -ForegroundColor Green
} elseif ($OS -like "*Darwin*" -or $env:OSTYPE -like "*darwin*") {
    # Mac environment
    $Environment = "mac"
    $ArchiveBasePath = "~/projects/secondbrain/$(Get-Date -Format 'yyyy\/MM\/dd')"
    Write-Host "Detected Mac environment - using ~/projects/secondbrain" -ForegroundColor Green
} elseif ($ComputerName -like "*XPS*" -or $ComputerName -like "*xps*" -or $ComputerName -like "*LaptopErdem*" -or $ComputerName -like "*laptoperdem*") {
    # Dell XPS native Windows
    $Environment = "xps"
    $ArchiveBasePath = "C:\projects\secondbrain\secondbrain\4_Archieve\$(Get-Date -Format 'yyyy\/MM\/dd')"
    Write-Host "Detected Dell XPS native Windows - using C:\projects\secondbrain\secondbrain\4_Archieve" -ForegroundColor Green
} else {
    # Fallback for unknown environments
    $Environment = "unknown"
    $ArchiveBasePath = "C:\projects\secondbrain\secondbrain\4_Archieve\$(Get-Date -Format 'yyyy\/MM\/dd')"
    Write-Host "Unknown environment - using default C:\projects\secondbrain\secondbrain\4_Archieve" -ForegroundColor Yellow
}

# Location verification clause
Write-Host "Environment detected: $Environment" -ForegroundColor Magenta
if ($Environment -eq "xps" -and $IsWSL) {
    Write-Host "✓ Confirmed: Running on Dell XPS in WSL2 environment" -ForegroundColor Green
    Write-Host "✓ Destination: C:\projects\secondbrain\secondbrain\4_Archieve" -ForegroundColor Green
} elseif ($Environment -eq "xps") {
    Write-Host "✓ Confirmed: Running on Dell XPS native Windows environment" -ForegroundColor Green
    Write-Host "✓ Destination: C:\projects\secondbrain\secondbrain\4_Archieve" -ForegroundColor Green
} elseif ($Environment -eq "workstation") {
    Write-Host "✓ Confirmed: Running on workstation environment" -ForegroundColor Green
    Write-Host "✓ Destination: F:\secondbrain_v4\secondbrain\secondbrain\4_Archieve" -ForegroundColor Green
} elseif ($Environment -eq "mac") {
    Write-Host "✓ Confirmed: Running on Mac environment" -ForegroundColor Green
    Write-Host "✓ Destination: ~/projects/secondbrain" -ForegroundColor Green
} else {
    Write-Host "⚠ Warning: Environment not fully recognized" -ForegroundColor Yellow
}

# Determine project title from parameter, cursor.md, or directory name
if (-not $ProjectTitle) {
    Write-Host "Reading project title from cursor.md..." -ForegroundColor Yellow
    
    # Read cursor.md to extract project title
    $CursorContent = Get-Content -Path "cursor.md" -Raw -ErrorAction SilentlyContinue
    if (-not $CursorContent) {
        Write-Host "ERROR: cursor.md not found! Cannot proceed without project title." -ForegroundColor Red
        exit 1
    }

    # Extract title from cursor.md (look for # Project Archive Index or similar)
    $TitleMatch = [regex]::Match($CursorContent, '#\s*(.+?)(?:\r?\n|$)')
    if ($TitleMatch.Success) {
        $ProjectTitle = $TitleMatch.Groups[1].Value.Trim()
        Write-Host "Found project title: $ProjectTitle" -ForegroundColor Green
    } else {
        # Fallback: use directory name
        $ProjectTitle = Split-Path (Get-Location) -Leaf
        Write-Host "No title found in cursor.md, using directory name: $ProjectTitle" -ForegroundColor Yellow
    }
} else {
    Write-Host "Using provided project title: $ProjectTitle" -ForegroundColor Green
}

# Create consistent archive location using project title
$ArchivePath = Join-Path $ArchiveBasePath $ProjectTitle

Write-Host "Starting archival process for: $ProjectTitle" -ForegroundColor Yellow
Write-Host "Archive location: $ArchivePath" -ForegroundColor Cyan
Write-Host "Workstation: $ComputerName" -ForegroundColor Cyan

# Create archive directory if it doesn't exist
if (!(Test-Path $ArchivePath)) {
    Write-Host "Creating archive directory: $ArchivePath" -ForegroundColor Cyan
    New-Item -ItemType Directory -Path $ArchivePath -Force | Out-Null
}

# Get current directory name for project identification
$ProjectName = Split-Path (Get-Location) -Leaf
$CurrentDate = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'

# Get all files in current directory, excluding the script, cursor.md, cleanup.ps1, .sh files, and report files
$SourceFiles = Get-ChildItem -Path . -File | Where-Object { $_.Name -ne "archive-project.ps1" -and $_.Name -ne "archive-project.sh" -and $_.Name -ne "cursor.md" -and $_.Name -ne "cleanup.ps1" -and $_.Name -ne "cleanup.sh" -and $_.Name -ne "ARCHIVE_SCRIPT_DEVELOPMENT_REPORT.md" -and $_.Name -ne "PROJECT_COMPLETION_REPORT.md" } | ForEach-Object { $_.Name }

Write-Host "Found $($SourceFiles.Count) files to archive" -ForegroundColor Cyan

# Archive each file
$ArchivedFiles = @()
foreach ($file in $SourceFiles) {
    $destination = Join-Path $ArchivePath $file
    Write-Host "Archiving: $file -> $destination" -ForegroundColor White
    
    Copy-Item -Path $file -Destination $destination -Force
    $ArchivedFiles += $file
    Write-Host "Successfully archived: $file" -ForegroundColor Green
}

# Create enhanced archive summary file with project title
$SummaryPath = Join-Path $ArchivePath "ARCHIVE_SUMMARY.md"
$SummaryLines = @(
    "# Project Archive Summary: $ProjectTitle",
    "",
    "## Archive Information",
    "- **Project Title**: $ProjectTitle",
    "- **Project Name**: $ProjectName",
    "- **Archive Date**: $CurrentDate",
    "- **Archive Location**: $ArchivePath",
    "- **Environment**: $Environment",
    "- **Computer Name**: $ComputerName",
    "- **WSL Environment**: $IsWSL",
    "- **Archive Base Path**: $ArchiveBasePath",
    "- **Total Files**: $($ArchivedFiles.Count)",
    "- **Script Used**: Enhanced archive-project.ps1",
    "",
    "## Project Overview",
    "This archive contains the complete project: **$ProjectTitle**",
    "",
    "## Archived Files"
)

foreach ($file in $ArchivedFiles) {
    $SummaryLines += "- $file"
}

$SummaryLines += @(
    "",
    "## Original Location",
    "- **Workspace**: $(Get-Location)",
    "- **Archive Index**: cursor.md (remains in workspace)",
    "- **Project Title Source**: cursor.md",
    "",
    "## Archive Benefits",
    "- **Consistent Location**: Always archives to the same base path",
    "- **Title-Based Organization**: Uses project title from cursor.md",
    "- **Date Organization**: Organized by year/month/day",
    "- **Complete Documentation**: Includes all project files and metadata",
    "",
    "## Usage",
    "Review the archived files to understand the project structure and functionality.",
    "The project title '$ProjectTitle' ensures consistent organization across archives.",
    "",
    "---",
    "*Archived by Enhanced PowerShell script: archive-project.ps1*",
    "*Project title extracted from: cursor.md*"
)

Set-Content -Path $SummaryPath -Value $SummaryLines -Encoding UTF8
Write-Host "Created enhanced archive summary: ARCHIVE_SUMMARY.md" -ForegroundColor Green

# Create a title-based README for the archive
$ReadmePath = Join-Path $ArchivePath "README.md"
$ReadmeLines = @(
    "# $ProjectTitle",
    "",
    "## Project Description",
    "This archive contains the complete project: **$ProjectTitle**",
    "",
    "## Archive Contents",
    "- **Source Files**: $($ArchivedFiles.Count) total files",
    "- **Documentation**: Comprehensive project documentation",
    "- **Archive Summary**: Complete metadata and file listing",
    "",
    "## Quick Start",
    "1. Review ARCHIVE_SUMMARY.md for complete file listing",
    "2. Check individual files for specific functionality",
    "3. Refer to cursor.md in the original workspace for context",
    "",
    "## Archive Details",
    "- **Archive Date**: $CurrentDate",
    "- **Original Project**: $ProjectName",
    "- **Archive Location**: $ArchivePath",
    "",
    "---",
    "*This README was automatically generated by archive-project.ps1*"
)

Set-Content -Path $ReadmePath -Value $ReadmeLines -Encoding UTF8
Write-Host "Created project README: README.md" -ForegroundColor Green

# Display enhanced archive results
Write-Host "=== Enhanced Archive Summary ===" -ForegroundColor Green
Write-Host "Workstation: $ComputerName" -ForegroundColor Cyan
Write-Host "Project Title: $ProjectTitle" -ForegroundColor Cyan
Write-Host "Project Name: $ProjectName" -ForegroundColor Cyan
Write-Host "Archive Location: $ArchivePath" -ForegroundColor Cyan
Write-Host "Archive Base Path: $ArchiveBasePath" -ForegroundColor Cyan
Write-Host "Files Archived: $($ArchivedFiles.Count)/$($SourceFiles.Count)" -ForegroundColor Cyan
Write-Host "Archive Summary: ARCHIVE_SUMMARY.md" -ForegroundColor Cyan
Write-Host "Project README: README.md" -ForegroundColor Cyan

if ($ArchivedFiles.Count -eq $SourceFiles.Count) {
    Write-Host "All files successfully archived!" -ForegroundColor Green
    Write-Host "Project '$ProjectTitle' has been moved to the second brain archive." -ForegroundColor Green
    Write-Host "cursor.md and archive-project.ps1 remain in the workspace." -ForegroundColor Green
    Write-Host "Archive uses consistent location based on project title from cursor.md" -ForegroundColor Green
} else {
    Write-Host "Some files failed to archive. Check the output above." -ForegroundColor Yellow
}

Write-Host "Enhanced archive process completed!" -ForegroundColor Green
Write-Host "Project title '$ProjectTitle' ensures consistent organization." -ForegroundColor Green

# Create a related title file for this archive
$TitleFileName = "title_$(Get-Date -Format 'yyyyMMdd_HHmmss').md"
$TitleContent = @"
# Archive Title: $ProjectTitle

## Archive Information
- **Project Title**: $ProjectTitle
- **Archive Date**: $CurrentDate
- **Archive Location**: $ArchivePath
- **Environment**: $Environment
- **Computer Name**: $ComputerName
- **Files Archived**: $($ArchivedFiles.Count)

## Related Archive
This title file was created for the archive: **$ProjectTitle**
Archived on: $CurrentDate
Location: $ArchivePath

---
*Generated by archive-project.ps1*
"@

Set-Content -Path $TitleFileName -Value $TitleContent -Encoding UTF8
Write-Host "Created related title file: $TitleFileName" -ForegroundColor Green

# Execute cleanup script if it exists
if (Test-Path "cleanup.ps1") {
    Write-Host "Executing cleanup script..." -ForegroundColor Yellow
    try {
        & ".\cleanup.ps1"
        Write-Host "Cleanup script executed successfully!" -ForegroundColor Green
    } catch {
        Write-Host "Error executing cleanup script: $($_.Exception.Message)" -ForegroundColor Red
    }
} else {
    Write-Host "No cleanup script found (cleanup.ps1)" -ForegroundColor Yellow
}

Write-Host "Enhanced archive process completed!" -ForegroundColor Green
Write-Host "Project title '$ProjectTitle' ensures consistent organization." -ForegroundColor Green
