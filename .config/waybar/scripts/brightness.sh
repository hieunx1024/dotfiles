#!/bin/bash

# Get current brightness percentage
BRIGHTNESS=$(brightnessctl -m | cut -d, -f4 | tr -d '%')

# If BRIGHTNESS is empty or not a number, set a default
if ! [[ "$BRIGHTNESS" =~ ^[0-9]+$ ]]; then
    BRIGHTNESS=50
fi

# Check if nightlight (wlsunset) is running
if pgrep -x "wlsunset" > /dev/null; then
    ICON="" # Moon icon for Night Light
    CLASS="nightlight"
    TOOLTIP="Độ sáng: ${BRIGHTNESS}% | Night Light: Đang bật"
else
    ICON="" # Sun icon for normal mode
    CLASS="normal"
    TOOLTIP="Độ sáng: ${BRIGHTNESS}% | Night Light: Đang tắt"
fi

# Output JSON for Waybar
echo "{\"text\": \"$ICON $BRIGHTNESS%\", \"class\": \"$CLASS\", \"tooltip\": \"$TOOLTIP\", \"percentage\": $BRIGHTNESS}"
