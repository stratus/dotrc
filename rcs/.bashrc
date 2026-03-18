# shellcheck shell=bash
alias ls="eza"
alias cat="bat"
alias top="htop"
alias grep="rg"

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/gfranco/.cache/lm-studio/bin"
# End of LM Studio CLI section

command -v fzf &>/dev/null && eval "$(fzf --bash)"

alias claude-corp='CLAUDE_CONFIG_DIR=~/.claude-corp claude'
command -v direnv &>/dev/null && eval "$(direnv hook bash)"
