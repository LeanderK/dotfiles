#!/bin/bash

#iterate over all the hidden folders in the current directory
#check whether they are symlinks
#if not move them to the specified directory
#and symlink them


folder_to_move_to="$1"

for f in .* ; do
    [[ "$f" == "." ]] && continue
    [[ "$f" == ".." ]] && continue


    [[ "$f" == ".local"* ]] && continue
    [[ "$f" == ".config"* ]] && continue
    [[ "$f" == ".oh-my-zsh"* ]] && continue
    [[ "$f" == ".conda"* ]] && continue

    if [ -d "$f" ] && [ ! -L "$f" ]; then
        echo -n "move hidden folder $f to $folder_to_move_to/$f? [y/n] "
        read ans
        if [ "$ans" == "y" ]; then
            mv "$f" "$folder_to_move_to"
            ln -s "$folder_to_move_to/$f" "$f"
        fi
    fi
done


