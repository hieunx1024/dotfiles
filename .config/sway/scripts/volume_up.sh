#!/bin/bash
LIMIT=150
CURRENT_VOL=$(pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\d+%' | head -1 | tr -d '%')

if [ $(($CURRENT_VOL + 5)) -gt $LIMIT ]; then
    pactl set-sink-volume @DEFAULT_SINK@ ${LIMIT}%
else
    pactl set-sink-volume @DEFAULT_SINK@ +5%
fi
