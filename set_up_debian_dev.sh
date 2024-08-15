#!/bin/bash
set -e

SCRIPT_DIR=$(dirname "$0")

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
  cp "$SCRIPT_DIR"/dotfiles_private/fonts/* ~/.local/share/fonts/
  rm ~/.local/share/fonts/MonacoNerdFont-Regular.ttf
  fc-cache -f
}

function setup_powerlevel10k() {
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" || true
  sed -i 's/ZSH_THEME=\"robbyrussell\"/ZSH_THEME=\"powerlevel10k\/powerlevel10k\"/g' "$HOME/.zshrc"
  cp "$SCRIPT_DIR/.p10k.zsh" "$HOME/"
}

function setup_sublimetext() {
  if ! [ -x "$(command -v subl)" ]; then
    wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/sublimehq-archive.gpg > /dev/null
    echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
    sudo apt update
    sudo apt install sublime-text -y
  fi
}

function setup_spotify() {
  if ! [ -x "$(command -v spotify)" ]; then
    curl -sS https://download.spotify.com/debian/pubkey_6224F9941A8AA6D1.gpg | sudo gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/spotify.gpg
    echo "deb http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list
    sudo apt-get update && sudo apt-get install spotify-client
   fi
}

function setup_flatpak() {
  if ! [ -x "$(command -v flatpak)" ]; then
    sudo apt install flatpak -y
    sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
  fi
}

function setup_open_any_terminal() {
  # to open from nautilus with wezterm
  # if /home/jorbik/.local/share/nautilus-python/extensions/nautilus_open_any_terminal.py does not exist
  if [ ! -f ~/.local/share/nautilus-python/extensions/nautilus_open_any_terminal.py ]; then
    cwd=$(pwd)
    cd /tmp
    sudo apt install gettext -y
    git clone https://github.com/Stunkymonkey/nautilus-open-any-terminal.git
    cd nautilus-open-any-terminal
    make

    make install schema      # User install
    gsettings set com.github.stunkymonkey.nautilus-open-any-terminal terminal wezterm
    sudo apt install python3-nautilus -y
    echo "To make the 'Open with Wezterm' work restart nautilus: 'nautilus -q'"
    cd "$cwd"
  fi
}

function setup_wezterm() {
  curl -fsSL https://apt.fury.io/wez/gpg.key | sudo gpg --yes --dearmor -o /usr/share/keyrings/wezterm-fury.gpg
  echo 'deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' | sudo tee /etc/apt/sources.list.d/wezterm.list
  sudo apt update
  sudo apt install wezterm -y

  # ubuntu specific - set up tdrop for wezterm activation with hotkey
  cwd=$(pwd)
  mkdir -p ~/.local/bin/
  cd ~/.local/bin/
  git clone https://github.com/noctuid/tdrop.git
  echo "Add custom hotkey in Ubuntu to activate wezterm with tdrop"
  echo "Command is: '$HOME/.local/bin/tdrop/tdrop -mta -h 100% wezterm'"
  echo "This will work work with nvidia drivers on the latest Ubuntu"
  # installing tdrop dependencies
  sudo apt install xdotool gawk -y
  cd "$cwd"
}

setup_nerdfont
setup_powerlevel10k
setup_sublimetext
setup_wezterm
setup_open_any_terminal
sudo apt install copyq -y

if [ "$optional_provided" == true ]; then
    echo "--optional was provided, installing optional tools."
    setup_spotify
    setup_flatpak
fi

if [ "$DESKTOP_SESSION" == "ubuntu" ]; then
  # disable meta+number key bindings - it interferes with wezterm
  gsettings set org.gnome.shell.extensions.dash-to-dock hot-keys false
  for i in $(seq 1 9); do gsettings set org.gnome.shell.keybindings "switch-to-application-${i}" '[]'; done
fi
