#!/usr/bin/env bash

set -x
set -e

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
ROOT_DIR=$(dirname "$SCRIPT_DIR")

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

# snippets
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  vscode_snippets_path="$HOME/.config/Code/User/snippets"
elif [[ "$OSTYPE" == "darwin"* ]]; then
  vscode_snippets_path="$HOME/Library/Application Support/Code/User/snippets"
else
  echo "OS type unknown. Exiting."
  exit 1
fi
mkdir -p "$(dirname "${vscode_snippets_path}")"
add "$SCRIPT_DIR/nvim/snippets" "${vscode_snippets_path}"

cd "$ROOT_DIR"

if ! [ -x "$(command -v stow)" ]; then
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    sudo apt install stow -y
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    if ! [ -x "$(command -v brew)" ]; then
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    brew install stow
  else
      echo "Unsupported OS"
  fi
fi

# Stow common config
stow -t ~ common
cd dotfiles_private/stow
stow -t ~ common_private
cd ../..

# Stow platform-specific config
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    stow -t ~ debian
    cd dotfiles_private/stow
    stow -t ~ debian_private
    cd ../..
    scripts/debian/install_min.sh
    scripts/debian/install.sh --optional
elif [[ "$OSTYPE" == "darwin"* ]]; then
    stow -t ~ macos
    cd dotfiles_private/stow
    stow -t ~ macos_private
    cd ../..
    scripts/macos/install.sh
else
    echo "Unsupported OS"
fi
