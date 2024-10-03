#!/bin/bash
set -e
set -x

SCRIPT_DIR=$(dirname "$0")

source "$SCRIPT_DIR/common.sh"

# Initialize a flag
optional_provided=false

# Loop through the arguments
for arg in "$@"; do
  if [ "$arg" == "--optional" ]; then
    optional_provided=true
    break
  fi
done

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
}

function setup_sublimetext() {
  if ! [ -x "$(command -v subl)" ]; then
    wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/sublimehq-archive.gpg >/dev/null
    echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
    sudo apt update
    sudo apt install sublime-text -y
  fi
}

function setup_spotify() {
  if ! [ -x "$(command -v spotify)" ]; then
    curl -sS https://download.spotify.com/debian/pubkey_6224F9941A8AA6D1.gpg | sudo gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/spotify.gpg
    echo "deb http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list
    sudo apt-get update && sudo apt-get install spotify-client -y || echo "Spotify installation failed. Consider installing outside of apt."
  fi
}

function setup_flatpak() {
  if ! [ -x "$(command -v flatpak)" ]; then
    sudo apt install flatpak -y
    sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
  fi
}

function setup_open_any_terminal() {
  # ubuntu specific
  if [ "$DESKTOP_SESSION" != "ubuntu" ]; then
    return
  fi
  # to open from nautilus with default terminal
  # if /home/jorbik/.local/share/nautilus-python/extensions/nautilus_open_any_terminal.py does not exist
  if [ ! -f ~/.local/share/nautilus-python/extensions/nautilus_open_any_terminal.py ]; then
    cwd=$(pwd)
    cd /tmp
    sudo apt install gettext -y
    git clone https://github.com/Stunkymonkey/nautilus-open-any-terminal.git
    cd nautilus-open-any-terminal
    make

    make install schema # User install
    gsettings set com.github.stunkymonkey.nautilus-open-any-terminal terminal alacritty
    sudo apt install python3-nautilus -y
    echo "To make the 'Open with <terminal>' work restart nautilus: 'nautilus -q'"
    cd "$cwd"
  fi
}

function setup_trdop() {
  cwd=$(pwd)
  mkdir -p ~/.local/bin/
  cd ~/.local/bin/
  git clone https://github.com/noctuid/tdrop.git
  echo "Add custom hotkey in Ubuntu to activate terminal with tdrop"
  echo "Command is: '$HOME/.local/bin/tdrop/tdrop -mta -h 100% <terminal_name>'"
  echo "This will work work with nvidia drivers on the latest Ubuntu"
  # installing tdrop dependencies
  sudo apt install xdotool gawk -y
  cd "$cwd"
}

function setup_wezterm() {
  curl -fsSL https://apt.fury.io/wez/gpg.key | sudo gpg --yes --dearmor -o /usr/share/keyrings/wezterm-fury.gpg
  echo 'deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' | sudo tee /etc/apt/sources.list.d/wezterm.list
  sudo apt update
  sudo apt install wezterm -y

  if [ "$DESKTOP_SESSION" == "ubuntu" ] && [[ ! -e "$HOME/.local/bin/tdrop/tdrop" ]]; then
    # ubuntu specific - set up tdrop for wezterm activation with hotkey
    setup_trdop
  fi
}

function setup_alacritty_source() {
  sudo apt install cmake pkg-config libfreetype6-dev libfontconfig1-dev libxcb-xfixes0-dev libxkbcommon-dev python3 gzip scdoc -y
  # install from source
  install_rust
  rustup override set stable
  rustup update stable
  cd /tmp
  rm -rf alacritty
  git clone https://github.com/alacritty/alacritty.git
  cd alacritty

  highest_tag=$(get_highest_tag_version)
  git checkout "$highest_tag"

  cargo build --release
  # terminfo
  infocmp alacritty || sudo tic -xe alacritty,alacritty-direct extra/alacritty.info
  # desktop entry
  sudo cp target/release/alacritty /usr/local/bin # or anywhere else in $PATH
  sudo cp extra/logo/alacritty-term.svg /usr/share/pixmaps/Alacritty.svg
  sudo cp extra/linux/Alacritty.desktop /usr/share/applications
  sudo desktop-file-install /usr/share/applications/Alacritty.desktop || echo "WARNING: Setting alacritty desktop entry failed."
  sudo update-desktop-database || echo "WARNING: Setting alacritty desktop entry failed."
  # manual page
  sudo mkdir -p /usr/local/share/man/man1
  sudo mkdir -p /usr/local/share/man/man5
  scdoc < extra/man/alacritty.1.scd | gzip -c | sudo tee /usr/local/share/man/man1/alacritty.1.gz > /dev/null
  scdoc < extra/man/alacritty-msg.1.scd | gzip -c | sudo tee /usr/local/share/man/man1/alacritty-msg.1.gz > /dev/null
  scdoc < extra/man/alacritty.5.scd | gzip -c | sudo tee /usr/local/share/man/man5/alacritty.5.gz > /dev/null
  scdoc < extra/man/alacritty-bindings.5.scd | gzip -c | sudo tee /usr/local/share/man/man5/alacritty-bindings.5.gz > /dev/null
  # completion
  mkdir -p ~/.zsh_functions
  grep -qxF 'fpath+=~/.zsh_functions' "$HOME"/.zshrc || echo 'fpath+=~/.zsh_functions' >>"$HOME"/.zshrc
  cp extra/completions/_alacritty ~/.zsh_functions/_alacritty
}

function setup_alacritty() {
  if ! [ -x "$(command -v alacritty)" ]; then
    sudo apt install alacritty -y || setup_alacritty_source
  fi
  if [ "$DESKTOP_SESSION" == "ubuntu" ]; then
    # ubuntu specific - set up tdrop for wezterm activation with hotkey
    if [[ ! -e "$HOME/.local/bin/tdrop/tdrop" ]]; then
      setup_trdop
    fi
    echo "Consider running these to set the default terminal"
    echo "sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator /usr/bin/alacritty 50"
    echo "sudo update-alternatives --config x-terminal-emulator"
  fi
}

setup_nerdfont
setup_powerlevel10k
setup_sublimetext
setup_wezterm
setup_open_any_terminal
sudo apt install copyq -y
setup_alacritty

if [ "$DESKTOP_SESSION" == "ubuntu" ]; then
  # disable meta+number key bindings - it interferes with wezterm
  gsettings set org.gnome.shell.extensions.dash-to-dock hot-keys false
  for i in $(seq 1 9); do gsettings set org.gnome.shell.keybindings "switch-to-application-${i}" '[]'; done
fi

if [ "$optional_provided" == true ]; then
  echo "--optional was provided, installing optional tools."
  setup_flatpak
  setup_spotify
fi
