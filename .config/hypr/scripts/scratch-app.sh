#!/usr/bin/env bash

set -u

class_regex="${1:?usage: scratch-app.sh CLASS_REGEX WORKSPACE [--show|--toggle]}"
workspace="${2:?usage: scratch-app.sh CLASS_REGEX WORKSPACE [--show|--toggle]}"
mode="${3:---toggle}"

# 1. Tìm thông tin cửa sổ khớp với class_regex
client_json="$(hyprctl clients -j 2>/dev/null \
    | jq -c --arg regex "$class_regex" '[.[] | select(.class | test($regex))][0] // empty')"

[[ -n "$client_json" ]] || exit 0

client_ws="$(jq -r '.workspace.name // ""' <<<"$client_json")"
client_addr="$(jq -r '.address // ""' <<<"$client_json")"

# 2. Lấy workspace hiện tại đang active
active_ws="$(hyprctl activeworkspace -j 2>/dev/null | jq -r '.name // "1"')"
visible_special="$(hyprctl monitors -j 2>/dev/null \
    | jq -r '[.[] | select(.focused)][0].specialWorkspace.name // ""')"

# Đóng overlay special workspace cũ nếu đang hiển thị dở
if [[ "$visible_special" == "special:$workspace" ]]; then
    hyprctl dispatch togglespecialworkspace "$workspace" >/dev/null
    sleep 0.05
fi

# 3. Nếu app đang nằm ở chính workspace hiện tại (tức là đang hiển thị trước mắt người dùng):
if [[ "$client_ws" == "$active_ws" ]]; then
    if [[ "$mode" == "--toggle" ]]; then
        # Người dùng bấm toggle -> cất toàn bộ cửa sổ của app này vào special workspace ẩn
        hyprctl clients -j 2>/dev/null \
            | jq -r --arg regex "$class_regex" --arg ws "$active_ws" \
                '.[] | select(.class | test($regex)) | select(.workspace.name == $ws) | .address' \
            | while read -r addr; do
                [[ -n "$addr" ]] && hyprctl dispatch movetoworkspacesilent "special:$workspace,address:$addr" >/dev/null
            done
        exit 0
    fi
fi

# 4. Khi cần hiển thị: Đưa app về NGAY WORKSPACE HIỆN TẠI (regular workspace)
# Nhờ chạy trên workspace thường, mọi tính năng xem ảnh, popup, menu, call của Qt/Wayland hoạt động 100% không bị xung đột overlay
hyprctl dispatch movetoworkspace "$active_ws,address:$client_addr" >/dev/null
hyprctl dispatch setfloating "address:$client_addr" >/dev/null
hyprctl dispatch resizewindowpixel "exact 1200 800,address:$client_addr" >/dev/null
hyprctl dispatch centerwindow "address:$client_addr" >/dev/null
hyprctl dispatch focuswindow "address:$client_addr" >/dev/null
