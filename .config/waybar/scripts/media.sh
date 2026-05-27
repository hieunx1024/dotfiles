#!/bin/bash
# High-reliability media player controller metadata helper for Waybar
# Uses playerctl follow (-F) to instantly push updates via DBus,
# and wraps in a safe loop if no players are active.

while true; do
    if pgrep -x "spotify" > /dev/null || pgrep -x "firefox" > /dev/null || playerctl -l &>/dev/null; then
        playerctl -a metadata --format '{"text": "{{title}}", "alt": "{{status}}", "class": "{{status}}"}' -F 2>/dev/null
    fi
    sleep 2
done
