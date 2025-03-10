#!/usr/bin/env bash

mkdir -p $HOME/.config || true
declare -a CONFIGS=("fish" "mc" "nvim" "wezterm" "borders" "aerospace")

if [ ! -d $PWD/dotfiles ]; then
  echo "This script needs to be run from repo directory"
  exit 1
fi

for CONF in "${CONFIGS[@]}"; do
  ln -s $PWD/dotfiles/$CONF $HOME/.config || echo "Cannot install config for '$CONF' maybe directory already exists?"
done
