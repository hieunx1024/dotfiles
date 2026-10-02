#!/bin/bash
# Nạp plugin overview (gọi bằng `exec =`, chạy lại mỗi lần reload - đã nạp thì bỏ qua).
# Cấu hình nằm ở hyprspace.conf; plugin tự reload config sau khi nạp nên áp dụng ngay.
#   Hyprspace (ưu tiên): mọi màn cùng lúc - build bằng scripts/build-hyprspace.sh
#   hyprexpo (dự phòng): sudo apt install hyprland-plugin-hyprexpo
HYPRSPACE=$HOME/.local/lib/hyprland/Hyprspace.so
HYPREXPO=/usr/lib/x86_64-linux-gnu/hyprland/plugins/libhyprexpo.so
LOADED=$(hyprctl plugin list)

if [ -f "$HYPRSPACE" ]; then
    grep -q hyprexpo <<<"$LOADED" && hyprctl plugin unload "$HYPREXPO" >/dev/null
    grep -q Hyprspace <<<"$LOADED" && exit 0
    hyprctl plugin load "$HYPRSPACE" >/dev/null
elif [ -f "$HYPREXPO" ]; then
    grep -q hyprexpo <<<"$LOADED" && exit 0
    hyprctl plugin load "$HYPREXPO" >/dev/null
else
    exit 0
fi
# Nạp xong reload để plugin đọc khối plugin {} (lần exec sau thấy đã nạp -> thoát, không lặp)
hyprctl reload >/dev/null
