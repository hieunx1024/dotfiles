#!/bin/bash
LIMIT=150
CURRENT_VOL=$(pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\d+%' | head -1 | tr -d '%')

if [ "$CURRENT_VOL" -lt "$LIMIT" ]; then
    pactl set-sink-volume @DEFAULT_SINK@ +5%
else
    pactl set-sink-volume @DEFAULT_SINK@ ${LIMIT}%
fi
