#!/bin/bash
# =============================================================================
# CLAMSHELL MODE HANDLER FOR SWAY
# Tự động quản lý màn hình laptop khi gập / mở nắp máy:
# - Gập máy (Lid closed): Nếu có màn ngoài -> tắt màn laptop, dồn workspace sang màn ngoài.
#                         Nếu KHÔNG có màn ngoài -> để systemd suspend máy.
# - Mở máy (Lid opened) : Bật lại màn laptop.
# =============================================================================

# Tìm tên màn hình laptop
PRIMARY=$(swaymsg -t get_outputs 2>/dev/null | jq -r '.[] | select(.name | startswith("eDP") or startswith("LVDS") or startswith("DSI")) | .name' | head -n 1)
PRIMARY=${PRIMARY:-"eDP-1"}

# Tìm màn hình ngoài đầu tiên (nếu có)
SECONDARY=$(swaymsg -t get_outputs 2>/dev/null | jq -r --arg prim "$PRIMARY" '.[] | select(.name != $prim and .active == true) | .name' | head -n 1)
if [ -z "$SECONDARY" ]; then
    SECONDARY=$(swaymsg -t get_outputs 2>/dev/null | jq -r --arg prim "$PRIMARY" '.[] | select(.name != $prim) | .name' | head -n 1)
fi

ACTION="$1"
# Nếu không truyền tham số, đọc trực tiếp trạng thái từ /proc/acpi/button/lid
if [ -z "$ACTION" ]; then
    if grep -q "closed" /proc/acpi/button/lid/*/state 2>/dev/null; then
        ACTION="close"
    else
        ACTION="open"
    fi
fi

case "$ACTION" in
    close|lid:on)
        if [ -n "$SECONDARY" ]; then
            # Có màn hình rời: bật màn ngoài trước tại tọa độ 0 0 (nếu chưa bật)
            swaymsg output "$SECONDARY" enable position 0 0
            
            # Tắt màn hình laptop: sway tự dời workspace của màn bị tắt sang màn ngoài, giữ nguyên
            # workspace đang xem (vòng lặp "workspace number 1..10" cũ tạo workspace rỗng và để
            # con trỏ ở workspace 10 sau khi gập máy)
            swaymsg output "$PRIMARY" disable
            notify-send "Chế độ Clamshell" "Đã gập máy: Màn hình laptop tắt, hiển thị trên màn ngoài ($SECONDARY)." -i video-display
        fi
        ;;
    open|lid:off)
        # Mở nắp máy: bật lại màn hình laptop tại vị trí 0 0
        swaymsg output "$PRIMARY" enable position 0 0
        
        # Nếu có màn ngoài đang hoạt động, xếp màn ngoài sang bên phải màn laptop
        if [ -n "$SECONDARY" ] && swaymsg -t get_outputs 2>/dev/null | jq -e --arg sec "$SECONDARY" '.[] | select(.name == $sec and .active == true)' >/dev/null 2>&1; then
            PRIMARY_WIDTH=$(swaymsg -t get_outputs 2>/dev/null | jq -r --arg prim "$PRIMARY" '.[] | select(.name == $prim) | .current_mode.width // .modes[0].width')
            PRIMARY_WIDTH=${PRIMARY_WIDTH:-1920}
            swaymsg output "$SECONDARY" enable position "$PRIMARY_WIDTH" 0
            notify-send "Chế độ Màn hình" "Đã mở máy: Bật lại màn hình laptop ($PRIMARY)." -i video-display
        fi
        ;;
esac
