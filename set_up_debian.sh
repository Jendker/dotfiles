#!/bin/bash
set -x
set -e

function get_highest_tag_version() {
  git tag | sort -V | tail -n 1
}

function is_installed() {
     dpkg --verify "$1" 2>/dev/null
}

function install_nvim_source() {
  branch_str="--branch stable"
  if [ -n "$1" ]; then
    branch_str="--branch $1"
  fi
  sudo apt-get install ninja-build gettext cmake unzip curl -y
  sudo apt install libreadline-dev -y # for hererocks
  cd /tmp && rm -rf neovim && git clone https://github.com/neovim/neovim.git $branch_str --single-branch
  cd neovim
  if [ "$1" == "master" ]; then
    # don't use latest stuff which breaks highlights
    git reset --hard 17f3a3a
  fi
  make CMAKE_BUILD_TYPE=RelWithDebInfo
  sudo make install
  cd .. && rm -rf neovim
}

function update_dotfiles() {
  cd /tmp/ && rm -rf dotfiles && git clone https://github.com/Jendker/dotfiles.git
  mkdir -p $HOME/.config
  bash dotfiles/install.sh --copy
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
    nvm_install_command="wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash"
    zsh -c "$nvm_install_command" || eval "$nvm_install_command"
    set +x
    # load nvm
    export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
    # add nvm to .zshrc with string does not exists after the installation
    if ! grep -Fxq 'export NVM_DIR="$HOME/.nvm"' $HOME/.zshrc; then
      sudo tee -a $HOME/.zshrc > /dev/null <<'EOT'
# Load nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
EOT
    fi
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

function update_git() {
  # need at least git 2.31
  version=$(git --version | tr -d -c 0-9.)
  major=`echo $version | cut -d. -f1`
  minor=`echo $version | cut -d. -f2`
  revision=`echo $version | cut -d. -f3`
  revision=`expr $revision + 1`

  if (( 2 > $major )) || (( 31 > $minor )); then
    echo "Updating git to the latest version..."
    sudo add-apt-repository ppa:git-core/ppa -y
    sudo apt-get update
    sudo apt-get install --upgrade git -y
  else
    echo "Git version $version is sufficient."
  fi
}

function install_rust() {
  if ! [ -x "$(command -v cargo)" ]; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    grep -qxF 'source "$HOME/.cargo/env"' $HOME/.zshrc || printf 'source "$HOME/.cargo/env"' >> $HOME/.zshrc
    echo "Please source ~/.zshrc or ~/.bashrc"
  fi
}

function install_rust_tree_sitter() {
  install_rust
  $HOME/.cargo/bin/cargo install tree-sitter-cli
}

function install_nvim_binary() {
  branch="stable"
  if [ -n "$1" ]; then
    branch="$1"
  fi
  install_nvim_source $branch
  install_node
  update_git
}

function install_zoxide() {
  if ! command -v zoxide > /dev/null 2>&1; then
    curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
  fi
  grep -qxF 'eval "$(zoxide init zsh)"' $HOME/.zshrc || printf 'eval "$(zoxide init zsh)"' >> $HOME/.zshrc
}

function install_yazi_source() {
  sudo test || true
  install_rust
  if ! command -v rustc > /dev/null 2>&1; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  fi
  cd /tmp && rm -rf yazi && git clone https://github.com/sxyazi/yazi.git
  cd yazi
  highest_tag=$(get_highest_tag_version)
  git checkout $highest_tag

  cargo build --release
  sudo cp ./target/release/yazi /usr/local/bin/
  cd .. && rm -rf yazi

  if ! grep -Fxq 'function ya() {' $HOME/.zshrc; then
    sudo tee -a $HOME/.zshrc > /dev/null <<'EOT'
function ya() {
  tmp="$(mktemp -t "yazi-cwd.XXXXX")"
  yazi "$@" --cwd-file="$tmp"
  if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
    cd -- "$cwd"
  fi
  rm -f -- "$tmp"
}
EOT
  fi
  install_zoxide
}

function install_conda() {
  # set up miniconda
  if ! [ -x "$(command -v conda)" ]; then
    mkdir -p ~/miniconda3
    wget "https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-$(uname --machine).sh" -O ~/miniconda3/miniconda.sh
    bash ~/miniconda3/miniconda.sh -b -u -p ~/miniconda3
    rm -rf ~/miniconda3/miniconda.sh
  fi

  git clone https://github.com/esc/conda-zsh-completion ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/conda-zsh-completion
  conda init zsh
  conda config --set auto_activate_base false
  sed -i 's/git-auto-fetch)/conda-zsh-completion git-auto-fetch)/g' $HOME/.zshrc
}

if [[ ! $# -eq 0 ]]; then
  if [[ $1 == "--update" ]]; then
    echo "Updating dotfiles..."
    update_dotfiles
    exit 0
  elif [[ $1 == "--update-nvim" ]]; then
    echo "Updating nvim binary..."
    install_nvim_source stable
    exit 0
  elif [[ $1 == "--update-nvim-dev" ]]; then
    echo "Updating nvim binary from git dev branch..."
    install_nvim_source master
    exit 0
  elif [[ $1 == "--install-node" ]]; then
    echo "Installing node js over nvm..."
    install_node
    exit 0
  elif [[ $1 == "--install-cargo" ]]; then
    echo "Installing rust and cargo..."
    install_rust
    exit 0
  elif [[ $1 == "--update-git" ]]; then
    echo "Updating git if necessary..."
    update_git
    exit 0
  elif [[ $1 == "--install-yazi" ]]; then
    echo "Installing yazi..."
    install_yazi_source
    exit 0
  elif [[ $1 == "--install-conda" ]]; then
    echo "Installing conda..."
    install_conda
    exit 0
  else
    echo "Option \"$1\" not recognized."
    exit 1
  fi
fi

sudo apt update
sudo apt install tmux curl wget locales lsb-release zsh xclip unzip python3-venv fd-find ccache git imagemagick pipx -y
# for thefuck
sudo apt install python3-dev python3-pip python3-setuptools -y
# symlink fdfind as fd
mkdir -p $HOME/.local/bin
ln -s $(which fdfind) $HOME/.local/bin/fd || true

sudo apt install ripgrep -y || true


# run set_up_common.sh
./set_up_common.sh

pipx install thefuck
if ! grep -q "alias vim=nvim" $HOME/.zshrc; then
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
export PATH="/usr/lib/ccache:$PATH"
eval $(thefuck --alias doit)
EOT
  # set plugin variables before sourcing oh-my-zsh
  ex -s $HOME/.zshrc <<\IN
/source \$ZSH\/oh-my-zsh.sh/i
# don't underline the paths with zsh-syntax-highlighting
(( ${+ZSH_HIGHLIGHT_STYLES} )) || typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[path]=none
ZSH_HIGHLIGHT_STYLES[path_prefix]=none

# zsh-expand
export ZPWR_EXPAND_BLACKLIST=(ls vim grep z zi)
export ZPWR_EXPAND_TO_HISTORY=true # expand to history also on enter

.
wq
IN
  sed -i 's/plugins=(git)/plugins=(git ubuntu zsh-syntax-highlighting zsh-expand git-auto-fetch)/g' $HOME/.zshrc
  sed -i '/mode auto/s/^# //g' $HOME/.zshrc
fi

sudo locale-gen en_US
sudo locale-gen en_US.UTF-8

# .tmux.conf
grep -qxF 'set-option -g default-shell /bin/zsh' $HOME/.tmux.conf || printf "set-option -g history-limit 125000\nset-option -g default-shell /bin/zsh" >> $HOME/.tmux.conf

# set up nvim
if ! [ -x "$(command -v nvim)" ]; then
  echo 'nvim is not installed. installing'
  install_nvim_binary stable
  update_dotfiles
fi

# set up pyenv only on bionic
if [[ $(lsb_release -cs) == "bionic" ]]; then
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
  pyenv global 3.8.15 || pyenv install 3.8.15 && pyenv global 3.8.15
fi

# set up fzf for zsh
if [ ! -d "$HOME/.fzf" ]; then
  git clone --depth 1 https://github.com/junegunn/fzf.git $HOME/.fzf
  $HOME/.fzf/install --key-bindings --completion --update-rc --no-bash
fi

# install git lfs
curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | sudo bash && sudo apt-get install git-lfs && git lfs install

install_zoxide

# set up gh
LATEST_VERSION=$(curl -s "https://api.github.com/repos/cli/cli/releases/latest" | grep -Po '"tag_name": "v\K[0-9.]+')
wget -O /tmp/gh.deb "https://github.com/cli/cli/releases/download/v${LATEST_VERSION}/gh_${LATEST_VERSION}_linux_$(dpkg --print-architecture).deb" && sudo dpkg -i /tmp/gh.deb && rm /tmp/gh.deb
echo "Optionally 'run gh auth login'"
echo "Done"
