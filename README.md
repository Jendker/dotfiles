# dotfiles

1. Clone:
```
git clone https://github.com/Jendker/dotfiles.git ~/.dotfiles
# to clone with the private dotfiles
git clone --recurse-submodules https://github.com/Jendker/dotfiles.git ~/.dotfiles
```

2. Install:
```
# MacOS or minimal debian install
~/.dotfiles/scripts/install.sh

# Full debian install for development machine
~/.dotfiles/scripts/install.sh --dev
```

3. Update:
```
cd ~/.dotfiles
git pull --recurse-submodules
# optionally to install added tools
~/.dotfiles/scripts/install.sh
# or
~/.dotfiles/scripts/install.sh --dev
```
