#!/bin/bash
# Lấy danh sách các cửa sổ và ID của chúng
list=$(swaymsg -t get_tree | jq -r '.. | select((.type? == "con" or .type? == "floating_con") and .name? != null and .name? != "" and (.app_id? != null or .window_properties.class? != null)) | "\(.id)\t[\(.app_id // .window_properties.class)] \(.name)"')

# Tính độ rộng phù hợp cho fuzzel, tối đa 100 ký tự
max_len=$(echo "$list" | awk -F'\t' '{len=length($2); if(len > 100) len=100; if (len > max) max = len} END {if(max<30) max=30; print max + 2}')

id=$(echo "$list" | fuzzel -d -p "" --hide-prompt --with-nth=2 --accept-nth=1 --minimal-lines -w $max_len)

if [ ! -z "$id" ]; then
    # Thêm delay nhỏ để chờ fuzzel đóng hẳn, tránh việc Sway tự trả focus về cửa sổ cũ
    sleep 0.1
    swaymsg "[con_id=$id] focus"
fi
