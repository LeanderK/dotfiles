#!/bin/bash

# Auto-update dotfiles repo once a month
# Checks timestamp file and pulls updates, then runs make update if changes detected

TIMESTAMP_FILE="$DOTFILES_DIR/autoupdate/.last_update"
ONE_MONTH_SECONDS=$((30 * 24 * 60 * 60))  # 30 days in seconds

# Check if it's time to update
if [[ -f "$TIMESTAMP_FILE" ]]; then
    LAST_UPDATE=$(cat "$TIMESTAMP_FILE")
    CURRENT_TIME=$(date +%s)
    TIME_DIFF=$((CURRENT_TIME - LAST_UPDATE))
    
    if [[ $TIME_DIFF -lt $ONE_MONTH_SECONDS ]]; then
        # Not yet time to update
        return 0
    fi
fi

echo "[dotfiles] checking for dotfiles updates..."

# Time to update - navigate to dotfiles directory
cd "$DOTFILES_DIR" || return 1

# Store the current HEAD commit
BEFORE_COMMIT=$(git rev-parse HEAD 2>/dev/null)

if [[ -z "$BEFORE_COMMIT" ]]; then
    # Not a git repo, skip
    return 0
fi

# Pull updates quietly
# echo "[dotfiles] Checking for updates..."
git fetch origin main --quiet 2>/dev/null

# Check if there are changes
if git diff --quiet HEAD origin/main; then
    echo "[dotfiles] Already up to date"
else
    echo "[dotfiles] Updates found, pulling changes..."
    git pull origin main --quiet
    
    AFTER_COMMIT=$(git rev-parse HEAD 2>/dev/null)
    
    # If the commit changed, we got updates - run make update
    if [[ "$BEFORE_COMMIT" != "$AFTER_COMMIT" ]]; then
        echo "[dotfiles] Running make update..."
        make -C "$DOTFILES_DIR" update
    fi
fi

# Update timestamp
date +%s > "$TIMESTAMP_FILE"
