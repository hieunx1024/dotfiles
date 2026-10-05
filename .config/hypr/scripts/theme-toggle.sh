#!/bin/bash
# Đổi nhanh giữa theme sáng White và theme tối dùng gần nhất.

HYPR="$HOME/.config/hypr"
current=$(cat "$HYPR/current_theme" 2>/dev/null || printf monochrome)
state="${XDG_STATE_HOME:-$HOME/.local/state}/hypr"
mkdir -p "$state"

case "$current" in
    white|sepia)
        target=$(cat "$state/last-dark-theme" 2>/dev/null || printf monochrome)
        case "$target" in monochrome|gruvbox|tokyonight|graphite|dracula) ;; *) target=monochrome ;; esac
        ;;
    *)
        printf '%s\n' "$current" > "$state/last-dark-theme"
        target=white
        ;;
esac

exec "$HYPR/scripts/theme-selector.sh" "$target"
