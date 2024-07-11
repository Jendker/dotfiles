#!/bin/bash

if [ -d ~/.oh-my-zsh ]; then
  echo "oh-my-zsh is installed"
else
  echo "installing oh-my-zsh"
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  sudo chsh -s $(which zsh) $(whoami) || true
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
  git clone https://github.com/MenkeTechnologies/zsh-expand.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-expand
fi

# auto setup remote for new branches
git config --global --add --bool push.autoSetupRemote true
# always rebase on pull
git config --global pull.rebase true

git config --global user.name "Jedrzej Orbik"
git config --global user.email Jendker@users.noreply.github.com

# copy the aliases
SCRIPT_DIR=$(dirname "$0")
cp "$SCRIPT_DIR/.aliases" ~/.aliases
grep -qxF 'source ~/.aliases' "$HOME/.zshrc" || echo 'source ~/.aliases' >> "$HOME/.zshrc"
grep -qxF 'eval "$(direnv hook zsh)"' $HOME/.zshrc || echo 'eval "$(direnv hook zsh)"' >> "$HOME/.zshrc"
mkdir -p ~/.config/direnv
echo '[global]
load_dotenv = true
strict_env = true' > ~/.config/direnv/direnv.toml

