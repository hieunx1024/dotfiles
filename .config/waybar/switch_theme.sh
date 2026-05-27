#!/bin/bash

THEME_DIR="$HOME/.config/waybar/themes"
WAYBAR_DIR="$HOME/.config/waybar"

# Get all available themes
THEMES=($(ls -d "$THEME_DIR"/*/ | xargs -n 1 basename))

if [ ${#THEMES[@]} -eq 0 ]; then
    echo "No themes found in $THEME_DIR"
    exit 1
fi

if [ -z "$1" ]; then
    # No theme specified, let's cycle
    if [ -L "$WAYBAR_DIR/config.jsonc" ]; then
        CURRENT_PATH=$(readlink -f "$WAYBAR_DIR/config.jsonc")
        CURRENT_THEME=$(basename $(dirname "$CURRENT_PATH"))
    else
        CURRENT_THEME="default"
    fi

    # Find index of current theme
    INDEX=-1
    for i in "${!THEMES[@]}"; do
       if [[ "${THEMES[$i]}" = "${CURRENT_THEME}" ]]; then
           INDEX=$i
           break
       fi
    done

    # Calculate next index
    NEXT_INDEX=$(( (INDEX + 1) % ${#THEMES[@]} ))
    THEME="${THEMES[$NEXT_INDEX]}"
else
    THEME="$1"
fi

if [ ! -d "$THEME_DIR/$THEME" ]; then
    echo "Theme '$THEME' does not exist."
    echo "Available themes: ${THEMES[*]}"
    exit 1
fi

# Remove existing config and style symlinks
rm -f "$WAYBAR_DIR/config.jsonc"
rm -f "$WAYBAR_DIR/style.css"

# Symlink new files
ln -s "$THEME_DIR/$THEME/config.jsonc" "$WAYBAR_DIR/config.jsonc"
ln -s "$THEME_DIR/$THEME/style.css" "$WAYBAR_DIR/style.css"

# Restart Waybar using Sway reload
swaymsg reload

echo "Switched to theme: $THEME"
