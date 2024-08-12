#!/usr/bin/env bash
set -e

rm -rf ~/.config/nvim
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  rm -rf "$HOME/.config/clangd"
elif [[ "$OSTYPE" == "darwin"* ]]; then
  rm -rf "$HOME/Library/Preferences/clangd/"
else
  echo "OS type unknown. Exiting."
  exit 1
fi
