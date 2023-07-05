#!/usr/bin/env bash

set -x
set -e

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

copy=false
if [[ $1 == "--copy" ]]; then
  copy=true
fi

function add() {
  rm -rf $2
  if [[ $copy == true ]]; then
    cp -r $1 $2
  else
    ln -s $1 $2
  fi
}

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  add "$SCRIPT_DIR/nvim" "$HOME/.config/nvim"
elif [[ "$OSTYPE" == "darwin"* ]]; then
  add "$SCRIPT_DIR/nvim/" "/Users/jedrzej/Library/Mobile Documents/com~apple~CloudDocs/Mackup/.config/nvim/"
else
  echo "OS type unknown. Exiting."
  exit 1
fi

# clangd
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  add "$SCRIPT_DIR/clangd" "$HOME/.config/clangd"
elif [[ "$OSTYPE" == "darwin"* ]]; then
  add "$SCRIPT_DIR/clangd/" "/Users/jedrzej/Library/Mobile Documents/com~apple~CloudDocs/Mackup/.config/clangd/"
else
  echo "OS type unknown. Exiting."
  exit 1
fi
