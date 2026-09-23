#!/bin/bash
wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-

vol=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -oP '[0-9.]+' | head -1)
if (( $(echo "$vol <= 0" | bc -l) )); then
    wpctl set-mute @DEFAULT_AUDIO_SINK@ 1
fi
