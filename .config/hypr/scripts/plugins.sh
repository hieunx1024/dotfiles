#!/bin/bash
# Nạp plugin overview (gọi bằng `exec =`, chạy lại mỗi lần reload - đã nạp thì bỏ qua).
# Lockfile ngăn recursive reload loop:
LOCK="/tmp/hypr_plugins_loading.lock"
if [ -f "$LOCK" ]; then
    exit 0
fi
touch "$LOCK"
trap 'rm -f "$LOCK"' EXIT

HYPRTASKING=$HOME/.local/lib/hyprland/hyprtasking.so
HYPRSPACE=$HOME/.local/lib/hyprland/Hyprspace.so
HYPREXPO=""
for p in \
    /usr/lib/x86_64-linux-gnu/hyprland/plugins/libhyprexpo.so \
    /usr/lib64/hyprland/plugins/libhyprexpo.so \
    /usr/lib/hyprland/plugins/libhyprexpo.so; do
    if [ -f "$p" ]; then
        HYPREXPO="$p"
        break
    fi
done
LOADED=$(hyprctl plugin list)

# Ưu tiên 1: Hyprtasking (3x3 grid overview, kéo thả cửa sổ)
if [ -f "$HYPRTASKING" ]; then
    grep -q hyprexpo <<<"$LOADED" && hyprctl plugin unload "$HYPREXPO" >/dev/null
    grep -q Hyprspace <<<"$LOADED" && hyprctl plugin unload "$HYPRSPACE" >/dev/null
    grep -qi hyprtasking <<<"$LOADED" && exit 0
    hyprctl plugin load "$HYPRTASKING" >/dev/null
elif [ -f "$HYPRSPACE" ]; then
    grep -q hyprexpo <<<"$LOADED" && hyprctl plugin unload "$HYPREXPO" >/dev/null
    grep -q Hyprspace <<<"$LOADED" && exit 0
    hyprctl plugin load "$HYPRSPACE" >/dev/null
elif [ -f "$HYPREXPO" ]; then
    grep -q Hyprspace <<<"$LOADED" && hyprctl plugin unload "$HYPRSPACE" >/dev/null
    grep -q hyprexpo <<<"$LOADED" && exit 0
    hyprctl plugin load "$HYPREXPO" >/dev/null
else
    exit 0
fi

# Nạp xong reload để plugin đọc khối plugin {}
hyprctl reload >/dev/null
