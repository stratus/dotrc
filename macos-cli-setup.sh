#!/usr/bin/env bash

# set -x # uncomment to debug

# tmux
if [ ! -r ~/.tmux/.tmux.conf.local ]; then
    cd ~ || exit
    git clone https://github.com/gpakosz/.tmux.git
    ln -s -f .tmux/.tmux.conf .
    cp .tmux/.tmux.conf.local .
    cd - || exit
fi


# vim
if [ ! -r ~/.vim_runtime/install_awesome_vimrc.sh ]; then
    cd ~ || exit
    git clone --depth=1 https://github.com/amix/vimrc.git ~/.vim_runtime
    sh ~/.vim_runtime/install_awesome_vimrc.sh
    cd - || exit
fi


# brew
which brew || (/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)" )
brew update

BREW_PACKAGES="pipx eza mtr pfetch golang git tree bat ripgrep tldr htop tmux jq yq shellcheck"
for p in $BREW_PACKAGES; do
    which "$p" || (brew install "$p")
done

# extras
pipx install autopep8
brew install git-lfs
brew install --cask zoom
brew install --cask microsoft-teams


# Mac
# Finder: Show hidden files
defaults write com.apple.finder AppleShowAllFiles YES

# Finder: Automatically open a new Finder window when a volume is mounted
defaults write com.apple.frameworks.diskimages auto-open-ro-root -bool true
defaults write com.apple.frameworks.diskimages auto-open-rw-root -bool true
defaults write com.apple.finder OpenWindowForNewRemovableDisk -bool true

# Finder: show path bar
defaults write com.apple.finder ShowPathbar -bool true
# Keep folders on top when sorting by name
defaults write com.apple.finder _FXSortFoldersFirst -bool true
# Display full POSIX path as Finder window title
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

# Avoid creating .DS_Store files on network or USB volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true
