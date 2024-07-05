#!/usr/bin/env zsh
set -e

SCRIPT_DIR=$(dirname $0)

SCRIPT_DIR/../set_up_common.sh

cp "/Users/jedrzej/Library/Mobile Documents/com~apple~CloudDocs/Random/Keyboard Layouts/Polish-German.bundle" "$HOME/Library/Keyboard Layouts/"
echo "Reboot and add the Polish-German keyboard layout from Polish keyboards"
