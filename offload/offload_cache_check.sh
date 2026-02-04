#!/bin/bash

# checks if .cache exists in folder_to_check_in and if not creates it

folder_to_check_in="$1"

if [ ! -d "$folder_to_check_in/.cache" ]; then
    echo -n "create hidden folder .cache in $folder_to_check_in"
    mkdir "$folder_to_check_in/.cache"
fi