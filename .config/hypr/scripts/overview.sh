#!/bin/bash
# Super+Tab: overview mọi workspace bằng hyprexpo; chưa có plugin thì dùng switcher fuzzel.
if hyprctl plugin list | grep -q hyprexpo; then
    hyprctl dispatch hyprexpo:expo toggle
else
    exec "$(dirname "$0")/window-switcher.sh"
fi
