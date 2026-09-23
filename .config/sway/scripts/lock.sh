#!/bin/bash
# Lock script with Catppuccin Mocha theme (Standard swaylock)

# Get current wallpaper from waypaper config if it exists
WALLPAPER=$(grep '^wallpaper =' ~/.config/waypaper/config.ini | cut -d ' ' -f 3 | sed "s|~|$HOME|")
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
