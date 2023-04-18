#!/bin/bash
set -x
set -e

function is_installed() {
     dpkg --verify "$1" 2>/dev/null
}

function install_nvim_source() {
  sudo apt-get install ninja-build gettext cmake unzip curl -y
  cd /tmp && rm -rf neovim && git clone https://github.com/neovim/neovim.git --branch stable --single-branch
  cd neovim
  make CMAKE_BUILD_TYPE=RelWithDebInfo
  sudo make install
  cd .. && rm -rf neovim
}

function update_nvim() {
  cd /tmp/ && rm -rf dotfiles && git clone https://github.com/Jendker/dotfiles.git
  cp -r dotfiles/nvim $HOME/.config/
  run_times=1
  nvim --headless "+Lazy! install" +qa
  # repeat again until successful
  while [ $? -ne 0 ]; do !!; done
  rm -rf dotfiles
}

function install_node() {
  installed=false
  if ! [ -x "$(command -v nvm)" ]; then
    echo "Installing nvm."
    wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
    set +x
    export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
    set -x
    installed=true
  fi
  set +x
  if [[ $(lsb_release -cs) == "bionic" ]]; then
    nvm install 16
  else
    nvm install --lts
  fi
  set -x
  if [ $installed = true ]; then
    echo "Please source ~/.zshrc or ~/.bashrc"
  fi
}

function install_cargo() {
  if ! [ -x "$(command -v cargo)" ]; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    grep -qxF 'source "$HOME/.cargo/env"' $HOME/.zshrc || printf "source "$HOME/.cargo/env"" >> $HOME/.zshrc
    echo "Please source ~/.zshrc or ~/.bashrc"
  fi
}

function install_nvim_binary() {
  install_nvim_source
  install_node
}

if [[ ! $# -eq 0 ]]; then
  if [[ $1 == "--update-nvim" ]]; then
    echo "Updating nvim..."
    update_nvim
    exit 0
  elif [[ $1 == "--update-nvim-bin" ]]; then
    echo "Updating nvim binary..."
    install_nvim_binary
    exit 0
  elif [[ $1 == "--install-node" ]]; then
    echo "Installing node js over nvm..."
    install_node
    exit 0
  elif [[ $1 == "--install-cargo" ]]; then
    echo "Installing cargo and rust..."
    install_cargo
    exit 0
  else
    echo "Option \"$1\" not recognized."
    exit 1
  fi
fi

sudo apt update
sudo apt install tmux zsh xclip unzip python3-venv fd-find -y
# symlink fdfind as fd
mkdir -p $HOME/.local/bin
ln -s $(which fdfind) $HOME/.local/bin/fd

sudo apt install ripgrep -y || true
if [ -d ~/.oh-my-zsh ]; then
	echo "oh-my-zsh is installed"
 else
 	echo "installing oh-my-zsh"
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  chsh -s $(which zsh) || true
  sudo tee -a $HOME/.zshrc > /dev/null <<'EOT'
alias vim=nvim
export EDITOR=nvim
alias venv="if [ -e ./venv/bin/activate ]; then source ./venv/bin/activate; else python3 -m venv venv && source ./venv/bin/activate; fi"
unsetopt BEEP
PROMPT="%(?:%{$fg_bold[green]%}➜ :%{$fg_bold[red]%}➜ )"
PROMPT+=' %{$fg[cyan]%}%~%{$reset_color%} $(git_prompt_info)'
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export PATH=$PATH:$HOME/.local/bin
EOT
sed -i 's/plugins=(git)/plugins=(git ubuntu)/g' $HOME/.zshrc
sed -i '/mode auto/s/^# //g' $HOME/.zshrc
fi

sudo locale-gen en_US
sudo locale-gen en_US.UTF-8

# .tmux.conf
grep -qxF 'set-option -g default-shell /bin/zsh' $HOME/.tmux.conf || printf "set-option -g history-limit 125000\nset-option -g default-shell /bin/zsh" >> $HOME/.tmux.conf

# set up nvim
if ! [ -x "$(command -v nvim)" ]; then
  echo 'nvim is not installed. installing'
  install_nvim_binary
  update_nvim
fi

# set up pyenv
if [ ! -d "$HOME/.pyenv" ]; then
  sudo apt install libreadline-dev libbz2-dev -y
  curl https://pyenv.run | bash
echo '# Load pyenv
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# Load pyenv-virtualenv automatically
eval "$(pyenv virtualenv-init -)"' >> $HOME/.zshrc
fi

if [[ $(lsb_release -cs) == "bionic" ]]; then
  pyenv global 3.8.15 || pyenv install 3.8.15 && pyenv global 3.8.15
fi
git config --global user.name "Jedrzej Orbik"
git config --global user.email jedrzej.orbik@roboception.de
# git config --global user.email Jendker@users.noreply.github.com
