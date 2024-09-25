#!/usr/bin/env bash

set -x
set -e

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
ROOT_DIR=$(dirname "$SCRIPT_DIR")

# Initialize flags
dev=false
copy=false
install_only=false

# Loop through the arguments
for arg in "$@"; do
  if [ "$arg" == "--copy" ]; then
    copy=true
  elif [ "$arg" == "--dev" ]; then
    dev=true
  elif [ "$arg" == "--optional" ]; then
    dev=true
  elif [ "$arg" == "--install-only" ]; then
    install_only=true
  fi
done

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

# Stow platform-specific config
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  prefix="debian"
elif [[ "$OSTYPE" == "darwin"* ]]; then
  prefix="macos"
else
  echo "Unsupported OS"
fi

if [[ $install_only != true ]]; then
  # Stow common config
  stow -t ~ common
  stow -t ~ "${prefix}"
fi

# Platform-specific config install
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  "${SCRIPT_DIR}/debian/install_min.sh"
  if [[ $dev == true ]]; then
    "${SCRIPT_DIR}/debian/install.sh" --optional
  fi
elif [[ "$OSTYPE" == "darwin"* ]]; then
  "${SCRIPT_DIR}/macos/install.sh"
else
  echo "Unsupported OS"
fi

# Private submodule install
SUBMODULE_PATH="dotfiles_private"
# Check if the submodule is not empty
if [[ -n "$(ls -A ${SUBMODULE_PATH})" ]]; then
  echo "Private submodule is available. Installing..."
  install_only_arg=""
  if [[ $install_only == true ]]; then
    install_only_arg="--install-only"
  fi
  "${SUBMODULE_PATH}/scripts/install.sh" $install_only_arg
else
  echo "Private submodule is not cloned. Skipping installation."
fi
