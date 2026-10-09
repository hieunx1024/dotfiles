#!/usr/bin/env bash

set -u

STATE_DIR="${XDG_RUNTIME_DIR:-/tmp}/hypr-scratch-state"
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

# 1. Lấy thông tin active monitor, active workspace, clients
monitors="$(hyprctl monitors -j 2>/dev/null)" || exit 0
active_mon="$(jq -c '[.[] | select(.focused)][0] // .[0]' <<<"$monitors")"
active_ws="$(jq -r '.activeWorkspace.name // "1"' <<<"$active_mon")"
visible_special="$(jq -r '.specialWorkspace.name // ""' <<<"$active_mon")"

# Nếu đang có overlay special workspace hiển thị, đóng nó lại trước
if [[ -n "$visible_special" ]]; then
    hyprctl dispatch togglespecialworkspace "${visible_special#special:}" >/dev/null
    sleep 0.05
fi

clients="$(hyprctl clients -j 2>/dev/null)" || exit 0

# 2. Tìm danh sách tất cả các ứng dụng scratchpad (bao gồm app trong special:* hoặc app scratchpad đang mở trên active_ws)
scratch_apps="$(jq -c --arg active_ws "$active_ws" '
    [
        .[]
        | . as $c
        | ($c.workspace.name) as $ws
        | ($c.class | ascii_downcase) as $cls
        | ($c.address | ltrimstr("0x")) as $raw_addr
        | (
            if ($cls | test("^(viber|viberpc)$")) then "viber"
            elif ($cls | test("^(spotify)$")) then "spotify"
            elif ($cls | test("^(discord|vesktop|webcord)$")) then "discord"
            elif ($ws | startswith("special:scratch-")) then ($ws | ltrimstr("special:"))
            else ("scratch-" + $raw_addr)
            end
          ) as $home_ws
        | select(
            ($ws | startswith("special:"))
            or (
                ($ws == $active_ws) and $c.floating and (
                    ($cls | test("^(viber|viberpc|spotify|discord|vesktop|webcord)$"))
                )
            )
          )
        | {
            address: $c.address,
            class: $c.class,
            current_ws: $ws,
            home_ws: $home_ws,
            is_on_active_ws: ($ws == $active_ws)
          }
    ]
' <<<"$clients")"

total_count="$(jq 'length' <<<"$scratch_apps")"
((total_count > 0)) || exit 0

# 3. Kiểm tra xem có app nào đang hiển thị trên active_ws không
current_index="$(jq -r '[.[] | .is_on_active_ws] | index(true) // -1' <<<"$scratch_apps")"

if ((current_index >= 0)); then
    # Đang có 1 app hiển thị trên active_ws: cất app này về home_ws của nó
    curr_home="$(jq -r ".[$current_index].home_ws" <<<"$scratch_apps")"
    curr_cls="$(jq -r ".[$current_index].class" <<<"$scratch_apps")"
    
    # Cất tất cả cửa sổ của app này trên active_ws (cửa sổ chính + cửa sổ popup/xem ảnh nếu có)
    hyprctl clients -j 2>/dev/null \
        | jq -r --arg cls "$curr_cls" --arg ws "$active_ws" \
            '.[] | select(.class == $cls and .workspace.name == $ws) | .address' \
        | while read -r a; do
            [[ -n "$a" ]] && hyprctl dispatch movetoworkspacesilent "special:$curr_home,address:$a" >/dev/null
        done
    
    # Nếu đây là app cuối cùng trong vòng lặp (hoặc chỉ có duy nhất 1 app), kết thúc (đã ẩn hết)
    if ((current_index == total_count - 1)); then
        exit 0
    fi
    next_index=$((current_index + 1))
else
    # Chưa có app nào trên active_ws: lấy app đầu tiên
    next_index=0
fi

# 4. Hiển thị app tại next_index ra active_ws (regular workspace)
next_addr="$(jq -r ".[$next_index].address" <<<"$scratch_apps")"
hyprctl dispatch movetoworkspace "$active_ws,address:$next_addr" >/dev/null
hyprctl dispatch setfloating "address:$next_addr" >/dev/null
hyprctl dispatch resizewindowpixel "exact 1200 800,address:$next_addr" >/dev/null
hyprctl dispatch centerwindow "address:$next_addr" >/dev/null
hyprctl dispatch focuswindow "address:$next_addr" >/dev/null
