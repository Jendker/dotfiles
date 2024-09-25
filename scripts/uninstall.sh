#!/usr/bin/env bash
set -e

# Unstow platform-specific config
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    cd dotfiles_private/stow
    stow -D -t ~ debian_private
    cd ../..
    stow -D -t ~ debian
elif [[ "$OSTYPE" == "darwin"* ]]; then
    cd dotfiles_private/stow
    stow -D -t ~ macos_private
    cd ../..
    stow -D -t ~ macos
else
    echo "Unsupported OS"
fi

# Unstow common
cd dotfiles_private/stow
stow -D -t ~ common_private
cd ../..
stow -D -t ~ common
