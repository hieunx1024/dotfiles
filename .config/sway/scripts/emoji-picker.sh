#!/usr/bin/env bash

# File containing emojis
EMOJI_FILE="/home/hieunx/.config/sway/scripts/emojis.txt"

# Run fuzzel in dmenu mode to pick an emoji
selected=$(/usr/bin/fuzzel --dmenu --prompt="Emoji: " < "$EMOJI_FILE")

# Extract the emoji (first character/word)
if [ -n "$selected" ]; then
    emoji=$(echo "$selected" | awk '{print $1}')
    
    # Copy to Wayland clipboard
    if command -v wl-copy &> /dev/null; then
        echo -n "$emoji" | wl-copy
    fi
    
    # Copy to X11 clipboard (for XWayland apps like Obsidian)
    if command -v xclip &> /dev/null; then
        echo -n "$emoji" | xclip -selection clipboard
    fi
    
    notify-send "Emoji Copied" "Copied $emoji to clipboard! Press Ctrl+V to paste." -i face-smile
fi
