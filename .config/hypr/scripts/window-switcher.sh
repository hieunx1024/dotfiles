#!/bin/bash
# Chọn cửa sổ bằng fuzzel rồi nhảy tới.
SELECTED=$(hyprctl clients -j \
    | jq -r '.[] | select(.workspace.id != -1 or (.workspace.name | startswith("special"))) | "\(.address)\t[\(.workspace.name)] \(.class) - \(.title)"' \
    | fuzzel --dmenu --with-nth=2 --accept-nth=1 -w 80 -p "󰖯 Window ❯ ")
[ -n "$SELECTED" ] && hyprctl dispatch focuswindow "address:$SELECTED"
