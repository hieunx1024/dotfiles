#!/usr/bin/env bash

set -u

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
class_regex="${1:?usage: scratch-app.sh CLASS_REGEX WORKSPACE [--show|--toggle]}"
workspace="${2:?usage: scratch-app.sh CLASS_REGEX WORKSPACE [--show|--toggle]}"
mode="${3:---toggle}"

# 1. Tìm thông tin cửa sổ khớp với class_regex
client_json="$(hyprctl clients -j 2>/dev/null \
    | jq -c --arg regex "$class_regex" '[.[] | select(.class | test($regex))][0] // empty')"

[[ -n "$client_json" ]] || exit 0

client_ws="$(jq -r '.workspace.name // ""' <<<"$client_json")"
client_addr="$(jq -r '.address // ""' <<<"$client_json")"

# 2. Lấy special workspace đang hiển thị trên màn hình hiện tại
visible_special="$(hyprctl monitors -j 2>/dev/null \
    | jq -r '[.[] | select(.focused)][0].specialWorkspace.name // ""')"

# 3. Nếu app đang ở trong một special workspace VÀ workspace đó đang hiển thị trên màn hình:
if [[ "$client_ws" == special:* && "$visible_special" == "$client_ws" ]]; then
    if [[ "$mode" == "--toggle" ]]; then
        # Đang hiển thị mà bấm toggle -> cất đi ngay lập tức
        special_name="${client_ws#special:}"
        hyprctl dispatch togglespecialworkspace "$special_name" >/dev/null
        exit 0
    fi
fi

# 4. Đảm bảo app nằm ở đúng special workspace chuyên dụng ($workspace)
if [[ "$client_ws" != "special:$workspace" ]]; then
    hyprctl dispatch setfloating "address:$client_addr" >/dev/null
    hyprctl dispatch resizewindowpixel "exact 1200 800,address:$client_addr" >/dev/null
    hyprctl dispatch movetoworkspacesilent "special:$workspace,address:$client_addr" >/dev/null
    sleep 0.05
    "$SCRIPT_DIR/recenter-scratchpads.sh"
fi

# 5. Nếu special workspace chưa hiển thị -> mở ra
if [[ "$visible_special" != "special:$workspace" ]]; then
    hyprctl dispatch togglespecialworkspace "$workspace" >/dev/null
    sleep 0.05
fi

hyprctl dispatch focuswindow "address:$client_addr" >/dev/null
