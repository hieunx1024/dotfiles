#!/bin/bash
export PATH="$HOME/.local/bin:$PATH"

# Lấy danh sách lịch sử clipboard từ cliphist và chọn bằng Fuzzel
selected=$(cliphist list | fuzzel -d -w 65 -l 12 -p "󰅍 Clipboard ❯ ")

if [ -n "$selected" ]; then
    echo "$selected" | cliphist decode | wl-copy
    notify-send -t 1000 -h string:x-canonical-private-synchronous:clipboard "Clipboard" "Đã copy mục đã chọn vào clipboard."
fi
