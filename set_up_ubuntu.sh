#!/bin/bash
set -x
set -e

function install_nvim_source() {
  sudo apt-get install ninja-build gettext libtool libtool-bin autoconf automake cmake g++ pkg-config unzip curl doxygen -y
  cd /tmp && git clone https://github.com/neovim/neovim.git --branch release-0.8
  cd neovim
  make CMAKE_BUILD_TYPE=Release
  sudo make install
}

sudo apt install tmux zsh xclip -y
if [ -d ~/.oh-my-zsh ]; then
	echo "oh-my-zsh is installed"
 else
 	echo "installing oh-my-zsh"
  sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" || true
  sudo tee -a $HOME/.zshrc > /dev/null <<EOT
alias vim=nvim
export EDITOR=nvim
alias venv="if [ -e ./venv/bin/activate ]; then source ./venv/bin/activate; else python3 -m venv venv && source ./venv/bin/activate; fi"
EOT
fi

# .tmux.conf
grep -qxF 'set-option -g default-shell /bin/zsh' $HOME/.tmux.conf || printf "set-option -g history-limit 125000\nset-option -g default-shell /bin/zsh" >> $HOME/.tmux.conf

# set up nvim
if ! [ -x "$(command -v nvim)" ]; then
  echo 'nvim is not installed. installing'
  wget https://github.com/neovim/neovim/releases/download/v0.8.0/nvim-linux64.deb --directory-prefix=/tmp
  sudo apt install /tmp/nvim-linux64.deb -y || install_nvim_source

  cd /tmp/ && git clone https://github.com/Jendker/dotfiles.git
  cp -r dotfiles/nvim $HOME/.config
  run_times=4
  for i in $(seq $run_times); do
    nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync'
  done
  # repeat again until successful
  while [ $? -ne 0 ]; do !!; done
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
