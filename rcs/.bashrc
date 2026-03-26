# shellcheck shell=bash
alias ls="eza"
alias cat="bat"
alias top="htop"
alias grep="rg"

# Added by LM Studio CLI (lms)
export PATH="$PATH:$HOME/.cache/lm-studio/bin"
# End of LM Studio CLI section

# ── fzf configuration ────────────────────────────────────────────────
if command -v fzf &>/dev/null; then

  # Use fd for file discovery (respects .gitignore, fast)
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'

  # Global defaults: layout, preview toggle, scrolling
  export FZF_DEFAULT_OPTS="
    --height=60%
    --layout=reverse
    --border=rounded
    --info=inline
    --bind='ctrl-/:toggle-preview'
    --bind='ctrl-d:preview-half-page-down'
    --bind='ctrl-u:preview-half-page-up'
    --bind='ctrl-a:select-all'
    --bind='ctrl-y:execute-silent(echo -n {+} | pbcopy)+abort'
  "

  # Ctrl+R: fuzzy history search with full-command preview
  export FZF_CTRL_R_OPTS="
    --preview='echo {}'
    --preview-window='up:3:wrap'
    --bind='ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort'
    --header='Ctrl-Y to copy · Ctrl-/ to toggle preview'
  "

  # Ctrl+T: fuzzy file finder with bat preview
  export FZF_CTRL_T_COMMAND='fd --type f --hidden --follow --exclude .git'
  export FZF_CTRL_T_OPTS="
    --preview='bat --color=always --style=numbers --line-range=:300 {}'
    --preview-window='right:60%:wrap'
    --header='Ctrl-/ to toggle preview'
  "

  # Alt+C: fuzzy cd with eza tree preview
  export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
  export FZF_ALT_C_OPTS="
    --preview='eza --tree --level=2 --color=always --icons {}'
    --preview-window='right:50%'
    --header='Ctrl-/ to toggle preview'
  "

  eval "$(fzf --bash)"
fi

# ── fzf helper functions ─────────────────────────────────────────────

# fbr — fuzzy git branch switcher
fbr() {
  local branch
  branch=$(git branch --all --sort=-committerdate |
    sed 's/^[* ]*//' |
    sed 's|^remotes/origin/||' |
    sort -u |
    fzf --preview='git log --oneline --graph --color=always -20 {}' \
        --header='Enter to switch branch') || return
  git checkout "$branch"
}

# fco — fuzzy git commit browser (view log, enter to show diff)
fco() {
  local commit
  commit=$(git log --oneline --color=always --decorate |
    fzf --ansi --no-sort \
        --preview='git show --color=always --stat {1}' \
        --header='Enter to show full diff') || return
  git show "$(echo "$commit" | awk '{print $1}')"
}

# fkill — fuzzy process killer
fkill() {
  local pid
  pid=$(ps -ef |
    sed 1d |
    fzf --multi --header='Tab to select multiple · Enter to kill' |
    awk '{print $2}') || return
  echo "$pid" | xargs kill -"${1:-9}"
}

command -v direnv &>/dev/null && eval "$(direnv hook bash)"

# Machine-specific overrides (not tracked in git)
# shellcheck source=/dev/null
source ~/.bashrc.local 2>/dev/null

