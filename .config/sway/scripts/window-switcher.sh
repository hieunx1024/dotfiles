#!/bin/bash
# Lấy danh sách các cửa sổ và ID của chúng, sau đó hiển thị qua rofi
list=$(swaymsg -t get_tree | jq -r '.. | select((.type? == "con" or .type? == "floating_con") and .name? != null and (.app_id? != null or .window_properties.class? != null)) | "\(.id)\t\(.app_id // .window_properties.class)"')
max_len=$(echo "$list" | awk -F'\t' '{if (length($2) > max) max = length($2)} END {print max + 2}')
id=$(echo "$list" | fuzzel -d -p "" --hide-prompt --with-nth=2 --accept-nth=1 --minimal-lines -w $max_len)

if [ ! -z "$id" ]; then
    swaymsg "[con_id=$id] focus"
fi
