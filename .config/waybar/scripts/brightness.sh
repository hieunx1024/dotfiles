#!/bin/bash

# Get current brightness percentage
BRIGHTNESS=$(brightnessctl -m | cut -d, -f4 | tr -d '%')

# If BRIGHTNESS is empty or not a number, set a default
if ! [[ "$BRIGHTNESS" =~ ^[0-9]+$ ]]; then
    BRIGHTNESS=50
fi

STATE_FILE="$HOME/.config/sway/nightlight_temp"
TEMP=4500
if [ -f "$STATE_FILE" ]; then
    SAVED_TEMP=$(cat "$STATE_FILE" 2>/dev/null)
    if [[ "$SAVED_TEMP" =~ ^[0-9]+$ ]]; then
        TEMP="$SAVED_TEMP"
    fi
fi

# Check if nightlight (wlsunset) is running
if pgrep -x "wlsunset" > /dev/null; then
    ICON="󰖔" # Monoline Moon icon for Night Light
    CLASS="nightlight"
    TOOLTIP=$(printf "Độ sáng: %s%%\nNight Light: Đang bật (%sK)\n\n• Chuột trái: Tắt\n• Chuột phải: Đổi nhiệt độ màu\n• Cuộn chuột: Chỉnh độ sáng" "$BRIGHTNESS" "$TEMP")
else
    ICON="󰃠" # Monoline Sun icon for normal mode
    CLASS="normal"
    TOOLTIP=$(printf "Độ sáng: %s%%\nNight Light: Đang tắt (%sK đã lưu)\n\n• Chuột trái: Bật\n• Chuột phải: Đổi nhiệt độ màu\n• Cuộn chuột: Chỉnh độ sáng" "$BRIGHTNESS" "$TEMP")
fi

# Output JSON for Waybar safely using jq
jq -n -c \
  --arg text "$ICON $BRIGHTNESS%" \
  --arg class "$CLASS" \
  --arg tooltip "$TOOLTIP" \
  --argjson percentage "$BRIGHTNESS" \
  '{text: $text, class: $class, tooltip: $tooltip, percentage: $percentage}'
