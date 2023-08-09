#!/usr/bin/env bash
nix eval --raw .\#nodeMeta."${1}".settings.host
