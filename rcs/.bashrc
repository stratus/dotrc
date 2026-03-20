# shellcheck shell=bash
alias ls="eza"
alias cat="bat"
alias top="htop"
alias grep="rg"

# Added by LM Studio CLI (lms)
export PATH="$PATH:$HOME/.cache/lm-studio/bin"
# End of LM Studio CLI section

command -v fzf &>/dev/null && eval "$(fzf --bash)"

command -v direnv &>/dev/null && eval "$(direnv hook bash)"

# Machine-specific overrides (not tracked in git)
# shellcheck source=/dev/null
source ~/.bashrc.local 2>/dev/null
