#!/bin/bash
set -e
set -x

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

if [ -d ~/.oh-my-zsh ]; then
  echo "oh-my-zsh is installed"
else
  echo "installing oh-my-zsh"
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  echo "Changing default shell, password required"
  sudo chsh -s "$(which zsh)" "$(whoami)" || true
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"/plugins/zsh-syntax-highlighting
  git clone https://github.com/MenkeTechnologies/zsh-expand.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"/plugins/zsh-expand
fi

# auto setup remote for new branches
git config --global --add --bool push.autoSetupRemote true
# always rebase on pull
git config --global pull.rebase true

git config --global user.name "Jedrzej Orbik"
git config --global user.email Jendker@users.noreply.github.com

grep -Fq 'source ~/.aliases' "$HOME/.zshrc" || echo '[ -e ~/.aliases ] && source ~/.aliases' >>"$HOME/.zshrc"
grep -Fxq 'export PATH=$PATH:$HOME/.local/bin' "$HOME/.zshrc" || echo 'export PATH=$PATH:$HOME/.local/bin' >>"$HOME/.zshrc"

if ! grep -qxF 'typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet' "$HOME"/.zshrc; then
  tee -a "$HOME"/.zshrc >/dev/null <<'EOT'
# don't show the warning which happens if direnv loads the .envrc file
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet
EOT
fi
if ! grep -qxF 'typeset -g POWERLEVEL9K_NODE_VERSION_PROJECT_ONLY=true' "$HOME"/.zshrc; then
  tee -a "$HOME"/.zshrc >/dev/null <<'EOT'
# show the node version only if it's set as a project version
typeset -g POWERLEVEL9K_NODE_VERSION_PROJECT_ONLY=true
EOT
fi
mkdir -p ~/.config/direnv
echo '[global]
load_dotenv = true
strict_env = true' >"$HOME"/.config/direnv/direnv.toml

alacritty_path="$HOME/.config/alacritty/alacritty.toml"
if [ ! -e "$alacritty_path" ]; then
  mkdir -p ~/.config/alacritty
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    cp "${SCRIPT_DIR}/debian/alacritty.toml" "$alacritty_path"
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    cp "${SCRIPT_DIR}/macos/alacritty.toml" "$alacritty_path"
  else
    echo "Unsupported OS"
    exit 1
  fi
fi
