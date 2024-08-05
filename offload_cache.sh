#!/bin/bash

# only moves the cache folder to the specified directory
# adds a check to zshrc to create if deleted

folder_to_move_to="$1"

if [ -d "$HOME/.cache" ] && [ ! -L "$HOME/.cache" ]; then
    echo -n "move hidden folder .cache to $folder_to_move_to/.cache? [y/n] "
    read ans
    if [ "$ans" == "y" ]; then
        mv "$HOME/.cache" "$folder_to_move_to"
        ln -s "$folder_to_move_to/.cache" "$HOME/.cache"

        # add check to zshrc

        # get absolute path to offload_cache_check.sh
        offload_cache_check_path=$(realpath offload_cache_check.sh)
        # add it to zshrc
        if ! grep -q "$offload_cache_check_path" ~/.zshrc; then
            echo "$offload_cache_check_path $folder_to_move_to" >> ~/.zshrc
        fi
    fi
fi