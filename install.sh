#!/usr/bin/env bash

# nvim
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  rm -rf ~/.config/nvim
  ln -s $(pwd)/nvim ~/.config/nvim
elif [[ "$OSTYPE" == "darwin"* ]]; then
  rm -r "/Users/jedrzej/Library/Mobile Documents/com~apple~CloudDocs/Mackup/.config/nvim/"
  cp -r $(pwd)/nvim/ "/Users/jedrzej/Library/Mobile Documents/com~apple~CloudDocs/Mackup/.config/nvim/"
else
  echo "OS type unknown. Exiting."
  exit 1
fi

# clangd
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  rm -rf ~/.config/clangd
  ln -s $(pwd)/clangd ~/.config/clangd
elif [[ "$OSTYPE" == "darwin"* ]]; then
  rm -r "/Users/jedrzej/Library/Mobile Documents/com~apple~CloudDocs/Mackup/.config/clangd/"
  cp -r $(pwd)/clangd/ "/Users/jedrzej/Library/Mobile Documents/com~apple~CloudDocs/Mackup/.config/clangd/"
else
  echo "OS type unknown. Exiting."
  exit 1
fi
