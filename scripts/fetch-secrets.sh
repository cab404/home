#!/usr/bin/env bash
set -e
shopt -s dotglob

cd "$(dirname "$0")/.."
host=$(./scripts/hostname.sh ${1})

echo fetching "$host":/secrets to secrets/"${1}"

rsync -avP root@"$host":/secrets/. secrets/"${1}-fetch"
