#!/bin/bash
# Quản lý tự động khóa màn hình và tắt màn hình theo nguồn điện (Pin / Sạc)
# - Dùng Pin: 10 phút (600s) khóa màn hình, 10s sau tắt màn hình
# - Cắm Sạc: 20 phút (1200s) khóa màn hình, 10s sau tắt màn hình
# - Tự động tôn trọng nút "Chặn khóa màn hình" (Idle Inhibitor) trên Waybar

PID_FILE="/tmp/sway-idle-manager.pid"
if [ -f "$PID_FILE" ]; then
    OLD_PID=$(cat "$PID_FILE")
    if kill -0 "$OLD_PID" 2>/dev/null; then
        kill "$OLD_PID" 2>/dev/null
        sleep 0.1
    fi
fi
echo "$$" > "$PID_FILE"

LOCK_SCRIPT="/home/hieunx/.config/sway/scripts/lock.sh"
CURRENT_STATE=""
CURRENT_PID=""

# Dừng mọi tiến trình swayidle cũ trước đó
pkill -x swayidle 2>/dev/null

is_ac() {
    for f in /sys/class/power_supply/*/online; do
        if [ -f "$f" ] && [ "$(cat "$f" 2>/dev/null)" = "1" ]; then
            return 0
        fi
    done
    for f in /sys/class/power_supply/*/status; do
        if [ -f "$f" ]; then
            local status
            status=$(cat "$f" 2>/dev/null)
            if [ "$status" = "Charging" ] || [ "$status" = "Full" ]; then
                return 0
            fi
        fi
    done
    return 1
}

cleanup() {
    [ -n "$CURRENT_PID" ] && kill "$CURRENT_PID" 2>/dev/null
    rm -f "$PID_FILE"
    exit 0
}

trap cleanup SIGTERM SIGINT SIGHUP EXIT

update_idle() {
    local target_state="BAT"
    if is_ac; then
        target_state="AC"
    fi

    # Nếu trạng thái nguồn không đổi và swayidle vẫn đang chạy thì giữ nguyên
    if [ "$CURRENT_STATE" = "$target_state" ] && [ -n "$CURRENT_PID" ] && kill -0 "$CURRENT_PID" 2>/dev/null; then
        return 0
    fi

    CURRENT_STATE="$target_state"
    if [ -n "$CURRENT_PID" ]; then
        kill "$CURRENT_PID" 2>/dev/null
        wait "$CURRENT_PID" 2>/dev/null
    fi

    if [ "$target_state" = "AC" ]; then
        # Cắm sạc (AC): 20 phút (1200s) lock, 1210s (sau đó 10s) tắt màn hình
        swayidle -w \
            timeout 1200 "$LOCK_SCRIPT" \
            timeout 1210 'swaymsg "output * dpms off"' \
            resume 'swaymsg "output * dpms on"' \
            before-sleep "$LOCK_SCRIPT" &
        CURRENT_PID=$!
    else
        # Dùng pin (Battery): 10 phút (600s) lock, 610s (sau đó 10s) tắt màn hình
        swayidle -w \
            timeout 600 "$LOCK_SCRIPT" \
            timeout 610 'swaymsg "output * dpms off"' \
            resume 'swaymsg "output * dpms on"' \
            before-sleep "$LOCK_SCRIPT" &
        CURRENT_PID=$!
    fi
}

# Khởi động lần đầu
update_idle

# Lắng nghe sự kiện cắm/rút sạc qua udevadm kết hợp kiểm tra định kỳ mỗi 10 giây
while true; do
    read -t 10 event
    update_idle
done < <(exec udevadm monitor --udev --subsystem-match=power_supply 2>/dev/null)
