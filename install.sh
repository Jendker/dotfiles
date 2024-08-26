#!/usr/bin/env bash

set -x
set -e

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

copy=false
if [[ $1 == "--copy" ]]; then
  copy=true
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
add "$SCRIPT_DIR/nvim" "$HOME/.config/nvim"

# clangd
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  add "$SCRIPT_DIR/clangd" "$HOME/.config/clangd"
elif [[ "$OSTYPE" == "darwin"* ]]; then
  macos_clangd_path="$HOME/Library/Preferences/clangd"
  mkdir -p "$macos_clangd_path"
  add "$SCRIPT_DIR/clangd" "$macos_clangd_path"
else
  echo "OS type unknown. Exiting."
  exit 1
fi

# tmux
add "$SCRIPT_DIR/.tmux.conf" "$HOME/.tmux.conf"

# .wezterm
add "$SCRIPT_DIR/.wezterm.lua" "$HOME/.wezterm.lua"
