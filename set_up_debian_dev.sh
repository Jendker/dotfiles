#!/bin/bash
set -x
set -e

SCRIPT_DIR=$(dirname "$0")

function setup_nerdfont() {
  mkdir -p ~/.local/share/fonts
  git clone https://github.com/epk/SF-Mono-Nerd-Font.git /tmp/SF-Mono-Nerd-Font
  cp /tmp/SF-Mono-Nerd-Font/*.otf ~/.local/share/fonts/
  rm -rf /tmp/SF-Mono-Nerd-Font
  fc-cache -f
}

function setup_powerlevel10k() {
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" || true
  sed -i 's/ZSH_THEME=\"robbyrussell\"/ZSH_THEME=\"powerlevel10k\/powerlevel10k\"/g' "$HOME/.zshrc"
  cp "$SCRIPT_DIR/.p10k.zsh" "$HOME/"
}

setup_nerdfont
setup_powerlevel10k
