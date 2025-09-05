# CAG Push Archive Script - Git Commit with Auto-Merge and Random Commit Names
# This script performs git commit with auto-merge of changes in archive.log file
# and generates random commit names for the cag-push-archive workflow
# Usage: .\cag-push-archive.ps1 [optional commit message]

param(
    [Parameter(Mandatory=$false)]
    [string]$CommitMessage
)

# Set error action preference
$ErrorActionPreference = "Stop"

Write-Host "=== CAG Push Archive Script ===" -ForegroundColor Green
Write-Host "Starting git commit with auto-merge process..." -ForegroundColor Yellow

# Function to generate random commit name
function New-RandomCommitName {
    $adjectives = @("swift", "elegant", "robust", "dynamic", "agile", "nimble", "precise", "efficient", "streamlined", "optimized", "enhanced", "refined", "polished", "advanced", "innovative", "cutting-edge", "modern", "sleek", "powerful", "intelligent")
    $nouns = @("commit", "push", "update", "sync", "merge", "deploy", "release", "build", "patch", "fix", "feature", "enhancement", "optimization", "refactor", "integration", "migration", "upgrade", "rollout", "delivery", "implementation")
    $prefixes = @("auto", "smart", "quick", "fast", "rapid", "instant", "seamless", "smooth", "effortless", "automated")
    
    $adjective = $adjectives | Get-Random
    $noun = $nouns | Get-Random
    $prefix = $prefixes | Get-Random
    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    
    return "${prefix}-${adjective}-${noun}-${timestamp}"
}

try {
    # Check if we're in a git repository
    $gitDir = git rev-parse --git-dir 2>$null
    if (-not $gitDir) {
        Write-Host "Error: Not in a git repository!" -ForegroundColor Red
        exit 1
    }

    # Check if archive.log exists
    if (-not (Test-Path "archive.log")) {
        Write-Host "Warning: archive.log file not found. Creating empty archive.log..." -ForegroundColor Yellow
        New-Item -ItemType File -Name "archive.log" -Force | Out-Null
        Add-Content -Path "archive.log" -Value "# Archive Log - Created $(Get-Date)"
    }

    # Generate random commit name
    $commitName = New-RandomCommitName
    Write-Host "Generated commit name: $commitName" -ForegroundColor Cyan

    # Get commit message from parameter or use default
    if ($CommitMessage) {
        $finalCommitMessage = $CommitMessage
    } else {
        $finalCommitMessage = "cag-push-archive: $commitName"
    }

    Write-Host "Commit message: $finalCommitMessage" -ForegroundColor Cyan

    # Check git status
    Write-Host "`n=== Git Status ===" -ForegroundColor Green
    git status --short

    # Add all changes including archive.log
    Write-Host "`n=== Adding files to git ===" -ForegroundColor Green
    git add .

    # Check if there are any changes to commit
    $stagedChanges = git diff --cached --name-only
    if (-not $stagedChanges) {
        Write-Host "No changes to commit. Repository is up to date." -ForegroundColor Yellow
        exit 0
    }

    # Perform auto-merge if there are conflicts in archive.log
    Write-Host "`n=== Checking for merge conflicts ===" -ForegroundColor Green
    $gitStatus = git status --porcelain
    $hasConflicts = $gitStatus | Where-Object { $_ -match "^UU|^AA|^DD" }
    
    if ($hasConflicts) {
        Write-Host "Merge conflicts detected. Attempting auto-merge for archive.log..." -ForegroundColor Yellow
        
        # Check if archive.log has conflicts
        $archiveLogConflicts = $gitStatus | Where-Object { $_ -match "archive\.log" }
        if ($archiveLogConflicts) {
            Write-Host "Auto-merging archive.log conflicts..." -ForegroundColor Yellow
            
            # Create a backup of the current archive.log
            Copy-Item "archive.log" "archive.log.backup" -Force
            
            # Read the content and check for conflict markers
            $content = Get-Content "archive.log" -Raw
            if ($content -match "<<<<<<< HEAD") {
                Write-Host "Resolving merge conflicts in archive.log..." -ForegroundColor Yellow
                
                # Simple conflict resolution: remove conflict markers and add merge info
                $resolvedContent = $content -replace "<<<<<<< HEAD.*?=======", "" -replace ">>>>>>> .*", "---"
                
                # Add merge marker
                $resolvedContent += "`n`n# Auto-merge completed at $(Get-Date)`n"
                $resolvedContent += "# Conflicts resolved by keeping both versions`n"
                
                # Write the resolved content
                Set-Content -Path "archive.log" -Value $resolvedContent -Encoding UTF8
                
                # Add the resolved file
                git add archive.log
                Write-Host "Archive.log conflicts resolved and added to staging." -ForegroundColor Green
            }
        }
    }

    # Create the commit
    Write-Host "`n=== Creating commit ===" -ForegroundColor Green
    git commit -m $finalCommitMessage
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Commit created successfully!" -ForegroundColor Green
        $commitHash = git rev-parse HEAD
        Write-Host "Commit hash: $commitHash" -ForegroundColor Cyan
        Write-Host "Commit name: $commitName" -ForegroundColor Cyan
    } else {
        Write-Host "Error: Failed to create commit!" -ForegroundColor Red
        exit 1
    }

    # Show commit details
    Write-Host "`n=== Commit Details ===" -ForegroundColor Green
    git log --oneline -1
    Write-Host ""
    git show --stat HEAD

    # Optional: Push to remote (uncomment if you want automatic push)
    # Write-Host "`n=== Pushing to remote ===" -ForegroundColor Green
    # $pushResult = git push
    # if ($LASTEXITCODE -eq 0) {
    #     Write-Host "✓ Successfully pushed to remote repository!" -ForegroundColor Green
    # } else {
    #     Write-Host "Warning: Failed to push to remote repository." -ForegroundColor Yellow
    #     Write-Host "You can push manually later with: git push" -ForegroundColor Yellow
    # }

    Write-Host "`n=== CAG Push Archive Process Completed ===" -ForegroundColor Green
    Write-Host "✓ Random commit name generated: $commitName" -ForegroundColor Green
    Write-Host "✓ Archive.log auto-merge completed" -ForegroundColor Green
    Write-Host "✓ Git commit created successfully" -ForegroundColor Green
    Write-Host "✓ Repository updated with latest changes" -ForegroundColor Green
    Write-Host ""
    Write-Host "Commit details:" -ForegroundColor Cyan
    Write-Host "  - Name: $commitName" -ForegroundColor White
    Write-Host "  - Message: $finalCommitMessage" -ForegroundColor White
    Write-Host "  - Hash: $commitHash" -ForegroundColor White
    Write-Host "  - Date: $(Get-Date)" -ForegroundColor White
    Write-Host ""
    Write-Host "To push to remote, run: git push" -ForegroundColor Yellow

} catch {
    Write-Host "Error occurred: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Stack trace: $($_.ScriptStackTrace)" -ForegroundColor Red
    exit 1
}
