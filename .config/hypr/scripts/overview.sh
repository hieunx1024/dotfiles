#!/bin/bash
# Super+Tab: overview mọi workspace. Hyprspace mở trên tất cả màn cùng lúc;
# không có thì hyprexpo (màn đang focus); không có plugin nào thì switcher fuzzel.
LOADED=$(hyprctl plugin list)
if grep -qi hyprtasking <<<"$LOADED"; then
    hyprctl dispatch hyprtasking:toggle cursor
elif grep -q hyprexpo <<<"$LOADED"; then
    hyprctl dispatch hyprexpo:expo toggle
elif grep -q Hyprspace <<<"$LOADED"; then
    hyprctl dispatch overview:toggle all
else
    exec "$(dirname "$0")/window-switcher.sh"
fi
