#!/usr/bin/env zsh
set -e

SCRIPT_DIR=$(dirname $0)
ROOT_DIR=$(dirname "$SCRIPT_DIR")

ROOT_DIR/set_up_common.sh

cp "/Users/jedrzej/Library/Mobile Documents/com~apple~CloudDocs/Random/Keyboard Layouts/Polish-German.bundle" "$HOME/Library/Keyboard Layouts/"
echo "Reboot and add the Polish-German keyboard layout from Polish keyboards"
cp ROOT_DIR/dotfiles_private/fonts/* ~/Library/Fonts/

SSH_CONFIG_PATH=/etc/ssh/sshd_config.d/100-macos.conf
if ! grep -Fxq "PasswordAuthentication no" "$SSH_CONFIG_PATH"; then
  echo "PasswordAuthentication no" >> "$SSH_CONFIG_PATH"
  echo "ChallengeResponseAuthentication no" >> "$SSH_CONFIG_PATH"
fi
