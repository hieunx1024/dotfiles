#!/usr/bin/env bash
# Tự động bung cửa sổ từ scratchpad khi click vào thông báo của app (Viber, Discord, Spotify).
set -u

app="${1:-}"

if [ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ] || [ "${XDG_CURRENT_DESKTOP:-}" = "Hyprland" ]; then
    case "$app" in
        viber)
            "$HOME/.config/hypr/scripts/scratch-app.sh" '(?i)viber' viber --show
            ;;
        discord)
            "$HOME/.config/hypr/scripts/scratch-app.sh" '(?i)(discord|vesktop|webcord)' discord --show
            ;;
        spotify)
            "$HOME/.config/hypr/scripts/spotify.sh" --show
            ;;
    esac
elif [ -n "${SWAYSOCK:-}" ] || [ "${XDG_CURRENT_DESKTOP:-}" = "sway" ]; then
    case "$app" in
        viber)
            swaymsg '[app_id="(?i)viber"] scratchpad show' 2>/dev/null || swaymsg '[class="(?i)viber.*"] scratchpad show' 2>/dev/null
            ;;
        discord)
            swaymsg '[class="(?i)discord"] scratchpad show' 2>/dev/null || swaymsg '[app_id="(?i)(discord|vesktop|webcord)"] scratchpad show' 2>/dev/null
            ;;
        spotify)
            swaymsg '[class="(?i)spotify"] scratchpad show' 2>/dev/null
            ;;
    esac
fi
