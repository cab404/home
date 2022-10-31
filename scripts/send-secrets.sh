#!/usr/bin/env bash
set -e
shopt -s dotglob

cd "$(dirname "$0")/.."
host=$(nix eval --raw .\#deploy.nodes."${1}".hostname)

echo going to send
ls -1 secrets/"${1}"/*
echo to "$host":/secrets
[ "$YOLO" ] || {
    read -p "R u sure? (λ to confirm) ⇒ " S
    [ "$S" == "λ" ] || exit 1
}

rsync -avp secrets/"${1}"/* root@"$host":/secrets
