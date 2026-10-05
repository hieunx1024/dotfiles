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

LOCK_SCRIPT="$HOME/.config/sway/scripts/lock.sh"

# Mặc định Ubuntu không dọn tiến trình khi logout (KillUserProcesses=no; máy này đã bật =yes, đây là lớp dự phòng). Không có kiểm tra này, idle-manager
# sót lại cứ 10s bật lại swayidle -> swayidle (kèm swaylock) bám vào phiên sau (Hyprland cũng dùng
# wayland-1 -> khoá màn 2 lần). Chạy tay ngoài sway (không tìm được PID) thì bỏ qua.
# PID của sway: đi ngược cây tiến trình; không phải con của sway (vd chạy qua nohup) thì hỏi xem tiến
# trình nào đang giữ socket $SWAYSOCK. KHÔNG suy từ tên socket: sway dùng lại SWAYSOCK có sẵn trong env
# (vd còn sót từ phiên trước) làm tên socket -> số trong tên có thể là PID của sway cũ đã chết
# (03/10: script canh tưởng sway đã thoát, dọn sạch phiên mới -> văng ra màn đăng nhập).
sway_pid() {
    local p=$$
    while [ "${p:-1}" -gt 1 ] 2>/dev/null; do
        [ "$(cat "/proc/$p/comm" 2>/dev/null)" = sway ] && { echo "$p"; return; }
        p=$(awk '/^PPid:/{print $2}' "/proc/$p/status" 2>/dev/null)
    done
    [ -n "$SWAYSOCK" ] && ss -xlpH 2>/dev/null | awk -v s="$SWAYSOCK" '$5==s' | grep -oE 'pid=[0-9]+' | head -1 | cut -d= -f2
}
SWAY_PID=$(sway_pid)
sway_alive() { [ -z "$SWAY_PID" ] || [ "$(cat "/proc/$SWAY_PID/comm" 2>/dev/null)" = sway ]; }
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
    # udevadm chạy trong process substitution không tự chết theo script -> mồ côi mỗi lần reload
    [ -n "$UDEV_PID" ] && kill "$UDEV_PID" 2>/dev/null
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
exec 3< <(exec udevadm monitor --udev --subsystem-match=power_supply 2>/dev/null)
UDEV_PID=$!
while true; do
    read -t 10 event <&3
    rc=$?
    sway_alive || exit 0   # trap EXIT -> cleanup: tắt swayidle + udevadm
    update_idle
    # rc 1..128 = EOF (udevadm đã chết): read trả về ngay -> tránh vòng lặp quay 100% CPU
    if [ "$rc" -gt 0 ] && [ "$rc" -le 128 ]; then sleep 10; fi
done
