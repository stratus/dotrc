#!/usr/bin/env bash

# set -x # uncomment to debug

# tmux
if [ ! -r ~/.tmux/.tmux.conf.local ]; then
    cd ~
    git clone https://github.com/gpakosz/.tmux.git
    ln -s -f .tmux/.tmux.conf
    cp .tmux/.tmux.conf.local .
    cd -
fi

# vim
if [ ! -r ~/.vim_runtime/install_awesome_vimrc.sh ]; then
    cd ~
    git clone --depth=1 https://github.com/amix/vimrc.git ~/.vim_runtime
    sh ~/.vim_runtime/install_awesome_vimrc.sh
    cd -
fi

# brew
which brew || (/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)" )

brew update

which pipx || (brew install pipx)
pipx install autopep8

which eza || (brew install eza)

which mtr || (brew install mtr)

which pfetch || (brew install pfetch)

which go || (brew install golang)

which git || (brew install git)
brew install git-lfs

which tree || (brew install tree)

which bat || (brew install bat)

which rg || (brew install ripgrep)

which tldr || (brew install tldr)

which htop || (brew install htop)

which tmux || (brew install tmux)

which jq || (brew install jq)

which yq || (brew install yq)

brew install --cask zoom
brew install --cask microsoft-teams


# Mac

# Finder: Show hidden files
defaults write com.apple.finder AppleShowAllFiles YES

# Finder: Automatically open a new Finder window when a volume is mounted
defaults write com.apple.frameworks.diskimages auto-open-ro-root -bool true
defaults write com.apple.frameworks.diskimages auto-open-rw-root -bool true
defaults write com.apple.finder OpenWindowForNewRemovableDisk -bool true

# Activity Monitor: Visualize CPU usage in the Activity Monitor Dock icon
defaults write com.apple.ActivityMonitor IconType -int 5

# Temperature monitoring: https://beebom.com/how-check-cpu-temperature-mac/, https://fannywidget.com/
brew install fanny

# Finder: show path bar
defaults write com.apple.finder ShowPathbar -bool true
# Keep folders on top when sorting by name
defaults write com.apple.finder _FXSortFoldersFirst -bool true
# Display full POSIX path as Finder window title
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

# Avoid creating .DS_Store files on network or USB volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true
