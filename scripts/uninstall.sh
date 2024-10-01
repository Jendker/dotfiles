#!/usr/bin/env bash
set -e

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
ROOT_DIR=$(dirname "$SCRIPT_DIR")

cd "$ROOT_DIR"

# Private submodule uninstall
SUBMODULE_PATH="dotfiles_private"

# Check if the submodule is not empty
if [[ -n "$(ls -A ${SUBMODULE_PATH})" ]]; then
  echo "Private submodule is available. Uninstalling..."
  "${SUBMODULE_PATH}/scripts/uninstall.sh"
else
  echo "Private submodule is not cloned. Skipping uninstallation."
fi

cd stow

# Unstow platform-specific config
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  stow --dotfiles -D -t ~ debian
elif [[ "$OSTYPE" == "darwin"* ]]; then
  stow --dotfiles -D -t ~ macos
else
  echo "Unsupported OS"
fi

# Unstow common
stow --dotfiles -D -t ~ common
