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
        | (
            if ($cls | test("^(viber|viberpc)$")) then 1
            elif ($cls | test("^(spotify)$")) then 2
            elif ($cls | test("^(discord|vesktop|webcord)$")) then 3
            else 4
            end
          ) as $priority
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
            title: $c.title,
            current_ws: $ws,
            home_ws: $home_ws,
            is_on_active_ws: ($ws == $active_ws),
            priority: $priority,
            is_main: (if ($cls | test("^(viber|viberpc)$")) then (if ($c.title | test("(?i)Rakuten Viber")) then 0 else 1 end) else 0 end)
          }
    ]
    | sort_by(.is_main)
    | unique_by(.home_ws)
    | sort_by(.priority, .home_ws)
' <<<"$clients")"

total_count="$(jq 'length' <<<"$scratch_apps")"
((total_count > 0)) || exit 0

# 3. Kiểm tra xem có app scratchpad nào đang hiển thị trên active_ws không
current_index="$(jq -r '[.[] | .is_on_active_ws] | index(true) // -1' <<<"$scratch_apps")"

if ((current_index >= 0)); then
    # Đang có 1 app hiển thị trên active_ws: cất app này về home_ws của nó
    curr_home="$(jq -r ".[$current_index].home_ws" <<<"$scratch_apps")"
    curr_cls="$(jq -r ".[$current_index].class" <<<"$scratch_apps")"
    
    # Cất tất cả cửa sổ của app này trên active_ws (cửa sổ chính + popup/xem ảnh nếu có)
    hyprctl clients -j 2>/dev/null \
        | jq -r --arg cls "$curr_cls" --arg ws "$active_ws" \
            '.[] | select((.class | ascii_downcase) == ($cls | ascii_downcase) and .workspace.name == $ws) | .address' \
        | while read -r a; do
            [[ -n "$a" ]] && hyprctl dispatch movetoworkspacesilent "special:$curr_home,address:$a" >/dev/null
        done
    
    # Lưu app tiếp theo cho lần bấm sau
    mkdir -p "$STATE_DIR"
    echo "$(( (current_index + 1) % total_count ))" > "$STATE_DIR/cycle_index"
    
    # Khi đã đóng app vào sp thì dừng lại, KHÔNG tự ý bung app khác ra!
    exit 0
fi

# 4. Khi chưa có app nào trên active_ws: hiển thị app được chọn
target_index=0
if [[ -f "$STATE_DIR/cycle_index" ]]; then
    saved_idx="$(cat "$STATE_DIR/cycle_index" 2>/dev/null || echo 0)"
    if [[ "$saved_idx" =~ ^[0-9]+$ ]] && ((saved_idx < total_count)); then
        target_index="$saved_idx"
    fi
else
    # Ưu tiên Viber nếu chưa có trạng thái lưu
    viber_idx="$(jq -r '[.[] | .home_ws == "viber"] | index(true) // -1' <<<"$scratch_apps")"
    if ((viber_idx >= 0)); then
        target_index="$viber_idx"
    fi
fi

# Hiển thị app tại target_index ra active_ws (regular workspace)
next_addr="$(jq -r ".[$target_index].address" <<<"$scratch_apps")"
target_cls="$(jq -r ".[$target_index].class" <<<"$scratch_apps")"
target_ws="$(jq -r ".[$target_index].current_ws" <<<"$scratch_apps")"

# Nếu app có nhiều cửa sổ ở target_ws (ví dụ Viber chính + popup/xem ảnh), đưa tất cả ra active_ws
if [[ "$target_ws" =~ ^special: ]]; then
    hyprctl clients -j 2>/dev/null \
        | jq -r --arg cls "$target_cls" --arg ws "$target_ws" \
            '.[] | select((.class | ascii_downcase) == ($cls | ascii_downcase) and .workspace.name == $ws) | .address' \
        | while read -r a; do
            [[ -n "$a" ]] && hyprctl dispatch movetoworkspace "$active_ws,address:$a" >/dev/null
        done
fi

hyprctl dispatch movetoworkspace "$active_ws,address:$next_addr" >/dev/null
hyprctl dispatch setfloating "address:$next_addr" >/dev/null
hyprctl dispatch resizewindowpixel "exact 1200 800,address:$next_addr" >/dev/null
hyprctl dispatch centerwindow "address:$next_addr" >/dev/null
hyprctl dispatch focuswindow "address:$next_addr" >/dev/null
