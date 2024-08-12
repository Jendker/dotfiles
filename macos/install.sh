#!/usr/bin/env zsh
set -e

SCRIPT_DIR=$(dirname $0)
ROOT_DIR=$(dirname "$SCRIPT_DIR")

$ROOT_DIR/set_up_common.sh

KEYBOARD_SOURCE_PATH="$HOME/Library/Mobile Documents/com~apple~CloudDocs/Random/Keyboard Layouts/Polish-German.bundle"
KEYBOARD_TARGET_PATH="$HOME/Library/Keyboard Layouts/Polish-German.bundle"
if [ -e "$KEYBOARD_SOURCE_PATH" ] && [ ! -e $KEYBOARD_TARGET_PATH ]; then
  cp "$KEYBOARD_SOURCE_PATH" "$KEYBOARD_TARGET_PATH"
  echo "Reboot and add the Polish-German keyboard layout from Polish keyboards"
fi
cp $ROOT_DIR/dotfiles_private/fonts/* ~/Library/Fonts/

SSH_CONFIG_PATH=/etc/ssh/sshd_config.d/100-macos.conf
if ! grep -Fxq "PasswordAuthentication no" "$SSH_CONFIG_PATH"; then
  echo "PasswordAuthentication no" | sudo tee -a "$SSH_CONFIG_PATH"
  echo "ChallengeResponseAuthentication no" | sudo tee -a "$SSH_CONFIG_PATH"
fi
