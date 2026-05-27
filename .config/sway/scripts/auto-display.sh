#!/bin/bash

# Ngăn chạy trùng lặp nhiều instance của script này
PID_FILE="/tmp/sway-auto-display.pid"
if [ -f "$PID_FILE" ]; then
    OLD_PID=$(cat "$PID_FILE")
    if kill -0 "$OLD_PID" 2>/dev/null; then
        kill "$OLD_PID" 2>/dev/null
        sleep 0.1
    fi
fi
echo "$$" > "$PID_FILE"

# Tự động tìm tên màn hình laptop chính (e.g. eDP-1)
PRIMARY=$(swaymsg -t get_outputs | jq -r '.[] | select(.name | startswith("eDP") or startswith("LVDS") or startswith("DSI")) | .name' | head -n 1)
if [ -z "$PRIMARY" ]; then
    PRIMARY="eDP-1"
fi

# Lắng nghe sự kiện thay đổi output từ Sway
swaymsg -m -t subscribe '["output"]' | while read -r event; do
    # Đếm số lượng màn hình đang hoạt động (active == true)
    ACTIVE_COUNT=$(swaymsg -t get_outputs | jq '[.[] | select(.active == true)] | length')
    
    # Nếu không còn màn hình nào hoạt động (bằng 0), tự động bật lại màn hình laptop
    if [ "$ACTIVE_COUNT" -eq 0 ]; then
        swaymsg output "$PRIMARY" enable position 0 0
        notify-send -u critical "Cấu hình Màn hình" "Đã tự động bật lại màn hình laptop ($PRIMARY) do ngắt kết nối màn ngoài."
    fi
done
