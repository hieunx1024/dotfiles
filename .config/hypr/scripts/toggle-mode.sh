#!/bin/bash
# =============================================================================
# Bật/tắt chế độ minimal của Waybar trên Hyprland
# =============================================================================

WAYBAR_DIR="$HOME/.config/hypr/waybar"

if grep -q '"group/center"' "$WAYBAR_DIR/config.jsonc" 2>/dev/null; then
    # Đang ở minimal -> chuyển sang full
    if [ -f "$WAYBAR_DIR/config-full.jsonc" ]; then
        cp "$WAYBAR_DIR/config-full.jsonc" "$WAYBAR_DIR/config.jsonc"
        cp "$WAYBAR_DIR/style-full.css" "$WAYBAR_DIR/style.css"
        MSG="Waybar: chế độ đầy đủ"
    fi
else
    # Đang ở full -> chuyển sang minimal
    if [ -f "$WAYBAR_DIR/config-minimal.jsonc" ]; then
        cp "$WAYBAR_DIR/config-minimal.jsonc" "$WAYBAR_DIR/config.jsonc"
        cp "$WAYBAR_DIR/style-minimal.css" "$WAYBAR_DIR/style.css"
        MSG="Waybar: chế độ minimal"
    fi
fi

pkill -SIGUSR2 waybar 2>/dev/null || true
notify-send "Waybar (Hyprland)" "${MSG:-Đã đổi chế độ}" -i preferences-desktop-theme
