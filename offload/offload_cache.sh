#!/bin/bash

# only moves the cache folder to the specified directory
# adds a check to zshrc to create if deleted

folder_to_move_to="$1"

if [ -z "$folder_to_move_to" ]; then
    echo "usage: $0 /path/to/target"
    exit 1
fi

if [ ! -d "$folder_to_move_to" ]; then
    echo "ERROR: target folder does not exist: $folder_to_move_to"
    exit 1
fi

if [ -d "$HOME/.cache" ] && [ ! -L "$HOME/.cache" ]; then
    echo -n "move hidden folder .cache to $folder_to_move_to/.cache? [y/n] "
    read ans
    if [ "$ans" == "y" ]; then
        mv "$HOME/.cache" "$folder_to_move_to"
        ln -s "$folder_to_move_to/.cache" "$HOME/.cache"

        # add check to zshrc

        # get absolute path to offload_cache_check.sh
        script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
        offload_cache_check_path="$script_dir/offload_cache_check.sh"
        # add it to zshrc
        if ! grep -q "$offload_cache_check_path" ~/.zshrc; then
            echo "$offload_cache_check_path $folder_to_move_to" >> ~/.zshrc
        fi
    fi
fi