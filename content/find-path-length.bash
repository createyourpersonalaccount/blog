#!/usr/bin/env bash

for path in "$@"; do
    IFS='/' read -r -a dirs <<< "$path"
    depth=${#dirs[@]}
    ((--depth))
    printf "%s " "$depth"
done
printf "\n"
