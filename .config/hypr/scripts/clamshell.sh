#!/bin/bash
# Gập máy khi đang cắm màn ngoài -> tắt eDP-1; mở máy -> bật lại.
# Không có màn ngoài thì để logind xử lý (suspend) như bình thường.
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

case "$1" in
    close)
        if [ "$(hyprctl monitors -j | jq 'length')" -gt 1 ]; then
            hyprctl keyword monitor "eDP-1, disable"
            sleep 0.35
            "$SCRIPT_DIR/recenter-scratchpads.sh"
        fi
        ;;
    open)
        hyprctl keyword monitor "eDP-1, 1920x1080, 0x0, 1"
        sleep 0.35
        "$SCRIPT_DIR/recenter-scratchpads.sh"
        ;;
esac
