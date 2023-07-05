#!/usr/bin/env bash

set -x
set -e

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

copy=false
dev=false
if [[ $1 == "--copy" ]]; then
  copy=true
elif [[ $1 == "--dev" ]]; then
  dev=true
fi

function add() {
  rm -r "$2" || true
  if [[ $copy == true ]]; then
    cp -r "$1" "$2"
  else
    ln -s "$1" "$2"
  fi
}

# nvim
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  add "$SCRIPT_DIR/nvim" "$HOME/.config/nvim"
elif [[ "$OSTYPE" == "darwin"* ]]; then
  config_folder="$HOME/.config/nvim"
  icloud_folder="$HOME/Library/Mobile Documents/com~apple~CloudDocs/Mackup/.config/nvim"
  if [[ $dev == true ]]; then
    copy=false
    add "$SCRIPT_DIR/nvim" "$config_folder"
  else
    copy=true
    add "$SCRIPT_DIR/nvim" "$icloud_folder"
    rm -r "$config_folder" || true
    ln -s "$icloud_folder" "$config_folder"
  fi
else
  echo "OS type unknown. Exiting."
  exit 1
fi

# clangd
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  add "$SCRIPT_DIR/clangd" "$HOME/.config/clangd"
elif [[ "$OSTYPE" == "darwin"* ]]; then
  copy=true
  add "$SCRIPT_DIR/clangd" "/Users/jedrzej/Library/Mobile Documents/com~apple~CloudDocs/Mackup/Library/Preferences/clangd/"
else
  echo "OS type unknown. Exiting."
  exit 1
fi
