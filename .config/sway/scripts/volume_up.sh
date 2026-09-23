#!/bin/bash
# LIMIT 150% via wpctl's boost factor (-l 1.5)
wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+
wpctl set-mute @DEFAULT_AUDIO_SINK@ 0
