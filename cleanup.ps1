# Cleanup script to remove files except specified ones
# Keep: archive-project.ps1, cleanup.ps1, cursor.md, title.md

Write-Host "Starting cleanup process..." -ForegroundColor Green

# Get all files in the current directory
$allFiles = Get-ChildItem -File

# Define files to keep
$filesToKeep = @(
    "archive-project.ps1",
    "cleanup.ps1", 
    "cursor.md",
    "title.md"
)

# Counter for removed files
$removedCount = 0

foreach ($file in $allFiles) {
    if ($filesToKeep -notcontains $file.Name) {
        try {
            Remove-Item $file.FullName -Force
            Write-Host "Removed: $($file.Name)" -ForegroundColor Yellow
            $removedCount++
        }
        catch {
            Write-Host "Error removing $($file.Name): $($_.Exception.Message)" -ForegroundColor Red
        }
    }
    else {
        Write-Host "Keeping: $($file.Name)" -ForegroundColor Green
    }
}

Write-Host "`nCleanup completed!" -ForegroundColor Green
Write-Host "Files removed: $removedCount" -ForegroundColor Cyan
Write-Host "Files remaining: $($filesToKeep.Count)" -ForegroundColor Cyan

# Show remaining files
Write-Host "`nRemaining files:" -ForegroundColor Green
Get-ChildItem -File | ForEach-Object { Write-Host "  - $($_.Name)" -ForegroundColor White }
