export BASH_SILENCE_DEPRECATION_WARNING=1

eval "$(/opt/homebrew/bin/brew shellenv)"

PF_INFO="title os host kernel uptime pkgs memory" pfetch 

source ~/.bashrc
