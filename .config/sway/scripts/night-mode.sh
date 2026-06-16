#!/bin/bash

# Check if wlsunset is installed
if ! command -v wlsunset &> /dev/null
then
    notify-send "Night Mode" "wlsunset is not installed. Please install it with: sudo pacman -S wlsunset" -u critical
    exit 1
fi

if pgrep -x "wlsunset" > /dev/null
then
    pkill -x wlsunset
    notify-send "Night Mode" "Blue light filter disabled" -i display-brightness-symbolic
else
    # -t and -T set to nearly same values forces the temperature immediately
    wlsunset -t 5000 -T 5001 &
    notify-send "Night Mode" "Blue light filter enabled (4500K)" -i display-brightness-symbolic
fi

# Update waybar backlight icon/tooltip
pkill -RTMIN+1 waybar
