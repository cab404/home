#!/usr/bin/env bash
# Collects all direnv nix shells in one place, and makes a list out of their dependencies
# Useful if you want to save all your deps

shells=( )
for a in ~/.config/direnv/allow/*; do
    a=$(cat "$a")
    [ -e "$a" ] || continue;
    ( grep use_nix "$a" > /dev/null ) || continue;
    a=$(dirname "$a")
    [ -e "$a/shell.nix" ] && shells+=( "$a/shell.nix" )
    [ -e "$a/default.nix" ] && shells+=( "$a/default.nix" )
done;

{
    echo '__concatStringsSep ":" (__concatLists (map (a: (map (d: "${d} ") (import a {}).buildInputs)) ['
    for shell in "${shells[@]}"; do
        # nix-shell "${shell}" --run "echo $shell"
        echo " \"${shell}\""
    done
    echo ' ]))'
} > ~/.direnv-packages.nix
