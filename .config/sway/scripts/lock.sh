#!/bin/bash
# Lock script with Catppuccin Mocha theme (Standard swaylock)

# Tránh mở nhiều instance swaylock đè lên nhau
if pgrep -x swaylock >/dev/null; then
    exit 0
fi

WALLPAPER=$(sed -n 's/^wallpaper[[:space:]]*=[[:space:]]*//p' ~/.config/waypaper/config.ini 2>/dev/null | head -n 1 | sed "s|^~|$HOME|")
[ -f "$WALLPAPER" ] || WALLPAPER=""

# Fallback color if no image
COLOR="1e1e2e"

# Colors (Catppuccin Mocha)
MAUVE="cba6f7"
RED="f38ba8"
GREEN="a6e3a1"
BASE="1e1e2e"
TEXT="cdd6f4"

IMAGE_ARGS=()
[ -n "$WALLPAPER" ] && IMAGE_ARGS=(--image "$WALLPAPER")

# Note: standard swaylock doesn't support --clock or --effects
swaylock -f \
	"${IMAGE_ARGS[@]}" \
	--scaling fill \
	--color $BASE \
	--ring-color $MAUVE \
	--key-hl-color $GREEN \
	--text-color $TEXT \
	--inside-color ${BASE}aa \
	--line-color 00000000 \
	--separator-color 00000000 \
	--ring-ver-color $MAUVE \
	--inside-ver-color ${BASE}aa \
	--ring-wrong-color $RED \
	--inside-wrong-color ${BASE}aa \
	--ring-clear-color $MAUVE \
	--inside-clear-color ${BASE}aa \
	--indicator-radius 100 \
	--indicator-thickness 7

# Khi đang ở màn hình khóa, nếu sau 10 giây không có thao tác chuột/phím thì tắt màn hình (dpms off)
(
    sleep 0.5
    if pgrep -x swaylock >/dev/null; then
        swayidle -w \
            timeout 10 'swaymsg "output * dpms off"' \
            resume 'swaymsg "output * dpms on"' &
        SUB_IDLE_PID=$!

        while pgrep -x swaylock >/dev/null; do
            sleep 1
        done

        kill "$SUB_IDLE_PID" 2>/dev/null
        swaymsg "output * dpms on"
    fi
) &
