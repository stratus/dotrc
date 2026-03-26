# shellcheck shell=bash
export BASH_SILENCE_DEPRECATION_WARNING=1

eval "$(/opt/homebrew/bin/brew shellenv)"

macchina

# ── fzf tip of the day ───────────────────────────────────────────────
_fzf_tips=(
  "Ctrl+R  → fuzzy search command history"
  "Ctrl+T  → insert a file path at your cursor (with bat preview)"
  "Alt+C   → cd into any directory (with tree preview)"
  "Ctrl+/  → toggle the preview window in any fzf prompt"
  "Ctrl+A  → select all results in fzf"
  "Ctrl+Y  → copy selection to clipboard and close fzf"
  "Ctrl+D / Ctrl+U  → scroll the preview pane up/down"
  "fbr     → fuzzy switch git branches (sorted by recent)"
  "fco     → browse git log, enter to see full diff"
  "fkill   → fuzzy kill processes (Tab to multi-select)"
  "vim **<Tab>  → fzf completion for file arguments"
  "cd **<Tab>   → fzf completion for directories"
  "ssh **<Tab>  → fzf completion for hostnames"
  "kill <Tab>   → fzf completion for PIDs"
  "export **<Tab> → fzf completion for environment variables"
)
printf '\e[2m  💡 %s\e[0m\n' "${_fzf_tips[RANDOM % ${#_fzf_tips[@]}]}"
unset _fzf_tips
# ──────────────────────────────────────────────────────────────────────

# shellcheck source=/dev/null
source ~/.bashrc

# Created by `pipx` on 2024-12-25 22:33:18
export PATH="$PATH:$HOME/.local/bin"
