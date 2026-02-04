#!/bin/bash

# Auto-update dotfiles repo once a month
# Checks timestamp file and pulls updates, then runs make update if changes detected

# Detect if script is sourced or executed
(return 0 2>/dev/null) && SOURCED=1 || SOURCED=0

# Parse arguments
VERBOSE=0
for arg in "$@"; do
    case "$arg" in
        -v|--verbose)
            VERBOSE=1
            ;;
    esac
done

# Set DOTFILES_DIR if not already set (for manual execution)
if [[ -z "$DOTFILES_DIR" ]]; then
    DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fi

TIMESTAMP_FILE="$DOTFILES_DIR/autoupdate/.last_update"
ONE_MONTH_SECONDS=$((30 * 24 * 60 * 60))  # 30 days in seconds

# print the file path for debugging in verbose mode
if [[ $VERBOSE -eq 1 ]]; then
    echo "[dotfiles] Timestamp file: $TIMESTAMP_FILE"
fi

# Check if it's time to update
if [[ -f "$TIMESTAMP_FILE" ]]; then
    LAST_UPDATE=$(cat "$TIMESTAMP_FILE")
    CURRENT_TIME=$(date +%s)
    TIME_DIFF=$((CURRENT_TIME - LAST_UPDATE))
    
    if [[ $TIME_DIFF -lt $ONE_MONTH_SECONDS ]]; then
        # Not yet time to update
        if [[ $VERBOSE -eq 1 ]]; then
            DAYS_LEFT=$(( (ONE_MONTH_SECONDS - TIME_DIFF) / 86400 ))
            echo "[dotfiles] Last checked recently. Next check in ~$DAYS_LEFT days."
        fi
        if [[ $SOURCED -eq 1 ]]; then
            return 0
        else
            exit 0
        fi
    fi
fi


echo "[dotfiles] checking for dotfiles updates..."


# Time to update - navigate to dotfiles directory
if ! cd "$DOTFILES_DIR"; then
    if [[ $SOURCED -eq 1 ]]; then
        return 1
    else
        exit 1
    fi
fi

# Store the current HEAD commit
BEFORE_COMMIT=$(git rev-parse HEAD 2>/dev/null)

if [[ -z "$BEFORE_COMMIT" ]]; then
    # Not a git repo, error
    echo "[dotfiles] ERROR: Not a git repository"
    if [[ $SOURCED -eq 1 ]]; then
        return 1
    else
        exit 1
    fi
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
