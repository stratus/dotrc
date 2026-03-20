# shellcheck shell=bash
export BASH_SILENCE_DEPRECATION_WARNING=1

eval "$(/opt/homebrew/bin/brew shellenv)"

macchina

# shellcheck source=/dev/null
source ~/.bashrc

# Created by `pipx` on 2024-12-25 22:33:18
export PATH="$PATH:$HOME/.local/bin"
