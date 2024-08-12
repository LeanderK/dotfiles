#!/bin/bash

#iterate over all the hidden folders in the current directory
#check whether they are symlinks
#if they are symlinks but the target is missing
#create target

#useful if you're working in a server enviroment with few, slow shared home-dir
#and fast local storage (for example offloading bigger folders to /scratch)

for f in .* ; do
    [[ "$f" == "." ]] && continue
    [[ "$f" == ".." ]] && continue

    [[ "$f" == ".local"* ]] && continue
    [[ "$f" == ".config"* ]] && continue
    [[ "$f" == ".oh-my-zsh"* ]] && continue
    [[ "$f" == ".conda"* ]] && continue

    if [ -L "$f" ] && [ ! -e "$f" ]; then
        echo "Broken symlink: $f"
        target=$(readlink "$f")
        echo "target $target for $f is missing, creating"
        mkdir -p "$target"
    fi

    if [ -d "$f" ] && [ -L "$f" ]; then
        target=$(readlink "$f")
        if [ ! -d "$target" ]; then
            echo "target $target for $f is missing, creating"
            #mkdir -p "$target"
        fi
    fi
done