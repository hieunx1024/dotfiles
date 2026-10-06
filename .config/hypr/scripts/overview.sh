#!/bin/bash
# Super+Tab / Cử chỉ touchpad: overview mọi workspace.
# Hỗ trợ action: toggle (mặc định), open, close.
ACTION=${1:-toggle}
LOADED=$(hyprctl plugin list)

if grep -qi hyprtasking <<<"$LOADED"; then
    case "$ACTION" in
        open)  hyprctl dispatch hyprtasking:if_not_active "hyprtasking:toggle cursor" ;;
        close) hyprctl dispatch hyprtasking:if_active "hyprtasking:toggle cursor" ;;
        *)     hyprctl dispatch hyprtasking:toggle cursor ;;
    esac
elif grep -q hyprexpo <<<"$LOADED"; then
    case "$ACTION" in
        open)  hyprctl dispatch hyprexpo:expo on ;;
        close) hyprctl dispatch hyprexpo:expo off ;;
        *)     hyprctl dispatch hyprexpo:expo toggle ;;
    esac
elif grep -q Hyprspace <<<"$LOADED"; then
    case "$ACTION" in
        open)  hyprctl dispatch overview:open all ;;
        close) hyprctl dispatch overview:close all ;;
        *)     hyprctl dispatch overview:toggle all ;;
    esac
else
    if [ "$ACTION" != "close" ]; then
        exec "$(dirname "$0")/window-switcher.sh"
    fi
fi
