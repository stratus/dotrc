#!/bin/bash
mouse_x=$1
w=$(tmux display-message -p '#{window_width}')
session_id=$(tmux display-message -p '#{session_id}')
NAME_STORE="/tmp/tmux-names-${session_id}"
STATE_FILE="/tmp/tmux-zoom-${session_id}"

touch "$NAME_STORE"

# Button zones (right-aligned, total 23 cols):
#  Zoom=6  Undo=6  Two=5  Four=6
if   [ "$mouse_x" -ge $((w-23)) ] && [ "$mouse_x" -lt $((w-17)) ]; then mode=zoom
elif [ "$mouse_x" -ge $((w-17)) ] && [ "$mouse_x" -lt $((w-11)) ]; then mode=undo
elif [ "$mouse_x" -ge $((w-11)) ] && [ "$mouse_x" -lt $((w-6))  ]; then mode=two
elif [ "$mouse_x" -ge $((w-6))  ]                                  ; then mode=four
else exit 0
fi

# ── helpers ──────────────────────────────────────────────────────────────────

save_name() {
  local pane_id="$1" name="$2"
  local tmp; tmp=$(mktemp)
  grep -v "^${pane_id} " "$NAME_STORE" > "$tmp" 2>/dev/null || true
  printf '%s %s\n' "$pane_id" "$name" >> "$tmp"
  mv "$tmp" "$NAME_STORE"
}

get_saved_name() {
  grep "^${1} " "$NAME_STORE" 2>/dev/null | cut -d' ' -f2-
}

win_for_pane() {
  # Returns window index that contains the given pane_id
  tmux list-panes -a -F '#{window_index} #{pane_id}' \
    | awk -v id="$1" '$2==id{print $1}'
}

lock_and_name() {
  local win_idx="$1" name="$2"
  [ -z "$win_idx" ] || [ -z "$name" ] && return
  tmux set-window-option -t ":${win_idx}" automatic-rename off
  tmux set-window-option -t ":${win_idx}" allow-rename off
  tmux rename-window -t ":${win_idx}" "$name"
}

pane_count() {
  tmux list-panes | wc -l | tr -d ' '
}

next_windows() {
  local count="$1"
  local current_win; current_win=$(tmux display-message -p '#{window_index}')
  tmux list-windows -F '#{window_index}' | sort -n \
    | awk -v cur="$current_win" '$1>cur{print $1}' | head -"$count"
}

# ── zoom ─────────────────────────────────────────────────────────────────────

do_zoom() {
  [ "$(pane_count)" -le 1 ] && exit 0

  # Save layout name (e.g. even-horizontal, tiled)
  local layout; layout=$(tmux display-message -p '#{window_layout}' | cut -d, -f1)
  rm -f "$STATE_FILE"
  echo "layout=${layout}" > "$STATE_FILE"

  # Save pane info then break each pane back to a window
  for idx in $(tmux list-panes -F '#{pane_index}' | sort -rn); do
    [ "$idx" = "0" ] && continue
    local pane_id; pane_id=$(tmux display-message -p -t ":.${idx}" '#{pane_id}')
    # Prefer name from store (set during Two/Four), fall back to pane title
    local name; name=$(get_saved_name "$pane_id")
    [ -z "$name" ] && name=$(tmux display-message -p -t ":.${idx}" '#{pane_title}')
    echo "pane=${pane_id} name=${name}" >> "$STATE_FILE"
    tmux break-pane -d -s ":.${idx}"
    local new_win; new_win=$(win_for_pane "$pane_id")
    lock_and_name "$new_win" "$name"
  done

  tmux move-window -r
}

# ── undo ─────────────────────────────────────────────────────────────────────

do_undo() {
  [ ! -f "$STATE_FILE" ] && exit 0

  local layout; layout=$(grep '^layout=' "$STATE_FILE" | cut -d= -f2-)

  while IFS= read -r line; do
    [[ "$line" =~ ^pane= ]] || continue
    local pane_id; pane_id="${line%% *}"; pane_id="${pane_id#pane=}"
    local name;    name="${line#pane=* name=}"
    local win_idx; win_idx=$(win_for_pane "$pane_id")
    [ -z "$win_idx" ] && continue
    save_name "$pane_id" "$name"
    tmux join-pane -h -s ":${win_idx}" -t ':.'
  done < "$STATE_FILE"

  tmux select-layout "$layout"
  rm -f "$STATE_FILE"
}

# ── two ───────────────────────────────────────────────────────────────────────

do_two() {
  [ "$(pane_count)" -gt 1 ] && exit 0

  local next; next=$(next_windows 1)
  [ -z "$next" ] && exit 0

  local pane_id; pane_id=$(tmux display-message -p -t ":${next}.0" '#{pane_id}')
  local name;    name=$(tmux display-message -p -t ":${next}" '#{window_name}')
  save_name "$pane_id" "$name"

  tmux join-pane -h -s ":${next}" -t ':.'
  tmux select-layout even-horizontal
}

# ── four ──────────────────────────────────────────────────────────────────────

do_four() {
  [ "$(pane_count)" -gt 1 ] && exit 0

  local wins; wins=$(next_windows 3)
  local count=0; for w in $wins; do count=$((count+1)); done
  [ "$count" -lt 3 ] && exit 0

  for widx in $wins; do
    local pane_id; pane_id=$(tmux display-message -p -t ":${widx}.0" '#{pane_id}')
    local name;    name=$(tmux display-message -p -t ":${widx}" '#{window_name}')
    save_name "$pane_id" "$name"
    tmux join-pane -h -s ":${widx}" -t ':.'
  done

  tmux select-layout tiled
}

# ── dispatch ──────────────────────────────────────────────────────────────────

case "$mode" in
  zoom) do_zoom ;;
  undo) do_undo ;;
  two)  do_two  ;;
  four) do_four ;;
esac
