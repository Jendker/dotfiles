function get_highest_tag_version() {
  git tag | grep -E '^v?[0-9]+(\.[0-9]+){1,2}$' | sort -V | tail -n 1
}

function install_rust() {
  if ! [ -x "$(command -v cargo)" ]; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    grep -qxF 'source "$HOME/.cargo/env"' $HOME/.zshrc || echo 'source "$HOME/.cargo/env"' >>$HOME/.zshrc
    echo "Please source ~/.zshrc or ~/.bashrc"
  fi
}
