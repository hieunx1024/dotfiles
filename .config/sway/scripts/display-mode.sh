#!/bin/bash

# 1. Tự động phát hiện màn hình
PRIMARY=$(swaymsg -t get_outputs | jq -r '.[] | select(.name | startswith("eDP") or startswith("LVDS") or startswith("DSI")) | .name' | head -n 1)
if [ -z "$PRIMARY" ]; then
    PRIMARY=$(swaymsg -t get_outputs | jq -r '.[0].name')
fi

SECONDARY=$(swaymsg -t get_outputs | jq -r --arg prim "$PRIMARY" '.[] | select(.name != $prim) | .name' | head -n 1)

# Kiểm tra nếu không có màn hình ngoài
if [ -z "$SECONDARY" ]; then
    notify-send -u critical "Cấu hình Màn hình" "Không tìm thấy màn hình ngoài nào được kết nối!"
    # Đảm bảo màn hình laptop luôn bật nếu không có màn hình ngoài
    swaymsg output "$PRIMARY" enable position 0 0
    exit 1
fi

# 2. Lấy độ phân giải động bằng jq
PRIMARY_WIDTH=$(swaymsg -t get_outputs | jq -r --arg prim "$PRIMARY" '.[] | select(.name == $prim) | .current_mode.width // .modes[0].width')
PRIMARY_HEIGHT=$(swaymsg -t get_outputs | jq -r --arg prim "$PRIMARY" '.[] | select(.name == $prim) | .current_mode.height // .modes[0].height')
SECONDARY_WIDTH=$(swaymsg -t get_outputs | jq -r --arg sec "$SECONDARY" '.[] | select(.name == $sec) | .current_mode.width // .modes[0].width')
SECONDARY_HEIGHT=$(swaymsg -t get_outputs | jq -r --arg sec "$SECONDARY" '.[] | select(.name == $sec) | .current_mode.height // .modes[0].height')

# Dự phòng nếu không lấy được độ phân giải
PRIMARY_WIDTH=${PRIMARY_WIDTH:-1920}
PRIMARY_HEIGHT=${PRIMARY_HEIGHT:-1080}
SECONDARY_WIDTH=${SECONDARY_WIDTH:-1920}
SECONDARY_HEIGHT=${SECONDARY_HEIGHT:-1080}

# 3. Các tùy chọn cho Menu Fuzzel
OPTIONS="💻 Chỉ màn hình laptop\n📺 Chỉ màn hình ngoài (Tự động chuyển workspace & tắt laptop)\n➡️ Mở rộng sang phải (Extend Right)\n⬅️ Mở rộng sang trái (Extend Left)\n⬆️ Mở rộng lên trên (Extend Up)\n🔄 Phản chiếu màn hình (Mirror - kế thừa toàn bộ workspace)"

CHOICE=$(echo -e "$OPTIONS" | fuzzel -d -p "Chọn chế độ màn hình: ")

# Hàm dọn dẹp các tiến trình wl-mirror cũ
cleanup_mirror() {
    pkill wl-mirror 2>/dev/null
}

case "$CHOICE" in
    *"Chỉ màn hình laptop"*)
        cleanup_mirror
        # Bật màn hình laptop trước
        swaymsg output "$PRIMARY" enable position 0 0
        # Đưa toàn bộ workspace về màn hình laptop
        for i in {1..10}; do
            swaymsg workspace number $i, move workspace to output "$PRIMARY"
        done
        # Tắt màn hình ngoài
        swaymsg output "$SECONDARY" disable
        notify-send "Cấu hình Màn hình" "Đã chuyển sang chỉ sử dụng màn hình Laptop ($PRIMARY)"
        ;;
    *"Chỉ màn hình ngoài"*)
        cleanup_mirror
        # Bật màn hình ngoài tại vị trí 0 0
        swaymsg output "$SECONDARY" enable position 0 0
        # Đưa toàn bộ workspace về màn hình ngoài (tự động kế thừa toàn bộ workspace)
        for i in {1..10}; do
            swaymsg workspace number $i, move workspace to output "$SECONDARY"
        done
        # Tắt màn hình laptop
        swaymsg output "$PRIMARY" disable
        notify-send "Cấu hình Màn hình" "Đã chuyển sang màn ngoài ($SECONDARY) & tắt màn Laptop"
        ;;
    *"Mở rộng sang phải"*)
        cleanup_mirror
        # Màn hình laptop làm tham chiếu ở (0, 0), màn ngoài ở bên phải (primary_width, 0)
        swaymsg output "$PRIMARY" enable position 0 0
        swaymsg output "$SECONDARY" enable position "$PRIMARY_WIDTH" 0
        notify-send "Cấu hình Màn hình" "Mở rộng: Màn laptop ($PRIMARY) bên TRÁI, Màn ngoài ($SECONDARY) bên PHẢI"
        ;;
    *"Mở rộng sang trái"*)
        cleanup_mirror
        # Màn hình laptop làm tham chiếu ở (secondary_width, 0), màn ngoài ở bên trái (0, 0)
        swaymsg output "$SECONDARY" enable position 0 0
        swaymsg output "$PRIMARY" enable position "$SECONDARY_WIDTH" 0
        notify-send "Cấu hình Màn hình" "Mở rộng: Màn ngoài ($SECONDARY) bên TRÁI, Màn laptop ($PRIMARY) bên PHẢI"
        ;;
    *"Mở rộng lên trên"*)
        cleanup_mirror
        # Màn hình ngoài làm tham chiếu ở (0, 0), màn laptop ở dưới (0, secondary_height)
        swaymsg output "$SECONDARY" enable position 0 0
        swaymsg output "$PRIMARY" enable position 0 "$SECONDARY_HEIGHT"
        notify-send "Cấu hình Màn hình" "Mở rộng: Màn ngoài ($SECONDARY) ở TRÊN, Màn laptop ($PRIMARY) ở DƯỚI"
        ;;
    *"Phản chiếu màn hình"*)
        cleanup_mirror
        # Bật màn hình laptop tại (0, 0)
        swaymsg output "$PRIMARY" enable position 0 0
        # Bật màn ngoài ở vị trí biệt lập (4000, 0) để khóa chuột không bị trôi
        swaymsg output "$SECONDARY" enable position 4000 0
        # Ép toàn bộ workspace (1-10) về màn hình laptop để wl-mirror kế thừa trọn vẹn
        for i in {1..10}; do
            swaymsg workspace number $i, move workspace to output "$PRIMARY"
        done
        
        # Đợi màn hình ngoài thực sự active trước khi khởi chạy wl-mirror
        for k in {1..20}; do
            if swaymsg -t get_outputs | jq -e --arg sec "$SECONDARY" '.[] | select(.name == $sec and .active == true)' >/dev/null; then
                break
            fi
            sleep 0.1
        done
        
        # Chạy wl-mirror toàn màn hình trên màn ngoài để phản chiếu màn laptop
        wl-mirror -b screencopy-shm --fullscreen-output "$SECONDARY" "$PRIMARY" >/dev/null 2>&1 &
        notify-send "Cấu hình Màn hình" "Đã phản chiếu màn hình (wl-mirror) - Kế thừa trọn vẹn toàn bộ workspace"
        ;;
    *)
        exit 1
        ;;
esac
