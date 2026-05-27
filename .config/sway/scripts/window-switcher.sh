#!/bin/bash
# Lấy danh sách các cửa sổ và ID của chúng, sau đó hiển thị qua fuzzel
window=$(swaymsg -t get_tree | jq -r '.. | select(.type? == "con" and .app_id? != null) | "\(.id): [\(.app_id)] \(.name)"' | fuzzel -d --placeholder "Chọn cửa sổ..." -w 80)

if [ ! -z "$window" ]; then
    id=$(echo $window | awk -F: '{print $1}')
    swaymsg "[con_id=$id] focus"
fi
