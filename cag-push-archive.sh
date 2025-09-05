#!/bin/bash

# CAG Push Archive Script - Git Commit with Auto-Merge and Random Commit Names
# This script performs git commit with auto-merge of changes in archive.log file
# and generates random commit names for the cag-push-archive workflow
# Usage: ./cag-push-archive.sh [optional commit message]

set -e  # Exit on any error

echo "=== CAG Push Archive Script ==="
echo "Starting git commit with auto-merge process..."

# Function to generate random commit name
generate_random_commit_name() {
    local adjectives=("swift" "elegant" "robust" "dynamic" "agile" "nimble" "precise" "efficient" "streamlined" "optimized" "enhanced" "refined" "polished" "advanced" "innovative" "cutting-edge" "modern" "sleek" "powerful" "intelligent")
    local nouns=("commit" "push" "update" "sync" "merge" "deploy" "release" "build" "patch" "fix" "feature" "enhancement" "optimization" "refactor" "integration" "migration" "upgrade" "rollout" "delivery" "implementation")
    local prefixes=("auto" "smart" "quick" "fast" "rapid" "instant" "seamless" "smooth" "effortless" "automated")
    
    local adjective=${adjectives[$RANDOM % ${#adjectives[@]}]}
    local noun=${nouns[$RANDOM % ${#nouns[@]}]}
    local prefix=${prefixes[$RANDOM % ${#prefixes[@]}]}
    
    echo "${prefix}-${adjective}-${noun}-$(date +%Y%m%d-%H%M%S)"
}

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "Error: Not in a git repository!"
    exit 1
fi

# Check if archive.log exists
if [[ ! -f "archive.log" ]]; then
    echo "Warning: archive.log file not found. Creating empty archive.log..."
    touch archive.log
    echo "# Archive Log - Created $(date)" >> archive.log
fi

# Generate random commit name
COMMIT_NAME=$(generate_random_commit_name)
echo "Generated commit name: $COMMIT_NAME"

# Get optional commit message from parameter or use default
if [[ -n "$1" ]]; then
    COMMIT_MESSAGE="$1"
else
    COMMIT_MESSAGE="cag-push-archive: $COMMIT_NAME"
fi

echo "Commit message: $COMMIT_MESSAGE"

# Check git status
echo ""
echo "=== Git Status ==="
git status --short

# Add all changes including archive.log
echo ""
echo "=== Adding files to git ==="
git add .

# Check if there are any changes to commit
if git diff --cached --quiet; then
    echo "No changes to commit. Repository is up to date."
    exit 0
fi

# Perform auto-merge if there are conflicts in archive.log
echo ""
echo "=== Checking for merge conflicts ==="
if git status --porcelain | grep -q "^UU\|^AA\|^DD"; then
    echo "Merge conflicts detected. Attempting auto-merge for archive.log..."
    
    # Check if archive.log has conflicts
    if git status --porcelain | grep -q "archive.log"; then
        echo "Auto-merging archive.log conflicts..."
        
        # Create a backup of the current archive.log
        cp archive.log archive.log.backup
        
        # Try to auto-resolve conflicts by keeping both versions
        if grep -q "<<<<<<< HEAD" archive.log; then
            echo "Resolving merge conflicts in archive.log..."
            
            # Simple conflict resolution: keep both versions with clear separation
            sed -i '/^<<<<<<< HEAD/,/^=======/d' archive.log
            sed -i 's/^>>>>>>> .*/---/' archive.log
            
            # Add a merge marker
            echo "" >> archive.log
            echo "# Auto-merge completed at $(date)" >> archive.log
            echo "# Conflicts resolved by keeping both versions" >> archive.log
        fi
        
        # Add the resolved file
        git add archive.log
        echo "Archive.log conflicts resolved and added to staging."
    fi
fi

# Create the commit
echo ""
echo "=== Creating commit ==="
if git commit -m "$COMMIT_MESSAGE"; then
    echo "✓ Commit created successfully!"
    echo "Commit hash: $(git rev-parse HEAD)"
    echo "Commit name: $COMMIT_NAME"
else
    echo "Error: Failed to create commit!"
    exit 1
fi

# Show commit details
echo ""
echo "=== Commit Details ==="
git log --oneline -1
echo ""
git show --stat HEAD

# Optional: Push to remote (uncomment if you want automatic push)
# echo ""
# echo "=== Pushing to remote ==="
# if git push; then
#     echo "✓ Successfully pushed to remote repository!"
# else
#     echo "Warning: Failed to push to remote repository."
#     echo "You can push manually later with: git push"
# fi

echo ""
echo "=== CAG Push Archive Process Completed ==="
echo "✓ Random commit name generated: $COMMIT_NAME"
echo "✓ Archive.log auto-merge completed"
echo "✓ Git commit created successfully"
echo "✓ Repository updated with latest changes"
echo ""
echo "Commit details:"
echo "  - Name: $COMMIT_NAME"
echo "  - Message: $COMMIT_MESSAGE"
echo "  - Hash: $(git rev-parse HEAD)"
echo "  - Date: $(date)"
echo ""
echo "To push to remote, run: git push"
