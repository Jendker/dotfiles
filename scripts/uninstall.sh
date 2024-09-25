#!/usr/bin/env bash
set -e

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
ROOT_DIR=$(dirname "$SCRIPT_DIR")

cd "$ROOT_DIR"

# Private submodule uninstall
SUBMODULE_PATH="dotfiles_private"
SUBMODULE_STATUS=$(git submodule status $SUBMODULE_PATH) || (git config --add safe.directory "${ROOT_DIR}" && SUBMODULE_STATUS=$(git submodule status $SUBMODULE_PATH))

# Check if the submodule is not empty
if [[ ! -z "$(ls -A ${SUBMODULE_PATH})" ]]; then
  echo "Private submodule is available. Uninstalling..."
  "${SUBMODULE_PATH}/scripts/uninstall.sh"
else
  echo "Private submodule is not cloned. Skipping uninstallation."
fi

# Unstow platform-specific config
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  stow -D -t ~ debian
elif [[ "$OSTYPE" == "darwin"* ]]; then
  stow -D -t ~ macos
else
  echo "Unsupported OS"
fi

# Unstow common
stow -D -t ~ common
