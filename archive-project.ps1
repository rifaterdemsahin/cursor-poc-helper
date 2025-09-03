# Enhanced Project Archive Script with Title from cursor.md
# This script reads the project title from cursor.md and uses it for consistent archiving

Write-Host "=== Enhanced Project Archive Script ===" -ForegroundColor Green
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

# Create consistent archive location using project title
$ArchiveBasePath = "F:\secondbrain_v4\secondbrain\secondbrain\4_Archieve\$(Get-Date -Format 'yyyy\/MM\/dd')\$ProjectTitle"
$ArchivePath = $ArchiveBasePath

Write-Host "Starting archival process for: $ProjectTitle" -ForegroundColor Yellow
Write-Host "Archive location: $ArchivePath" -ForegroundColor Cyan

# Create archive directory if it doesn't exist
if (!(Test-Path $ArchivePath)) {
    Write-Host "Creating archive directory: $ArchivePath" -ForegroundColor Cyan
    New-Item -ItemType Directory -Path $ArchivePath -Force | Out-Null
}

# Get current directory name for project identification
$ProjectName = Split-Path (Get-Location) -Leaf
$CurrentDate = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'

# Get all files in current directory, excluding the script and cursor.md
$SourceFiles = Get-ChildItem -Path . -File | Where-Object { $_.Name -ne "archive-project.ps1" -and $_.Name -ne "cursor.md" } | ForEach-Object { $_.Name }

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
Write-Host "Project Title: $ProjectTitle" -ForegroundColor Cyan
Write-Host "Project Name: $ProjectName" -ForegroundColor Cyan
Write-Host "Archive Location: $ArchivePath" -ForegroundColor Cyan
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
