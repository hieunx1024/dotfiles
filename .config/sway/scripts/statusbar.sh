#!/bin/bash
# Chạy waybar (config mặc định ~/.config/waybar), tự bật lại nếu crash.
# waybar 0.15 segfault trong module mpris (Glib::Dispatcher khi libplayerctl báo player mới)
# -> mất thanh bar giữa giờ làm. Chỉ restart khi chết vì SIGSEGV(139)/SIGABRT(134);
# pkill waybar (reload sway, đổi theme) thì vòng lặp dừng hẳn, không sinh bản trùng.
# Tên file cố ý không chứa "waybar": các lệnh `pkill waybar`/`pkill -USR1 waybar` khớp
# theo tên tiến trình, nếu không sẽ bắn nhầm vào chính script này.
pkill -x waybar 2>/dev/null
# Compositor đã chết (logout/crash) thì không restart nữa - tránh vòng lặp mỗi giây khi không còn màn hình
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
COMP_PID=$(sway_pid); COMP_NAME=sway
compositor_alive() { [ -z "$COMP_PID" ] || [ "$(cat "/proc/$COMP_PID/comm" 2>/dev/null)" = "$COMP_NAME" ]; }
while true; do
    # waybar sinh "swaync-client -swb" cho module thông báo; waybar bị tắt/crash thì nó mồ côi và tích tụ
    # (03/10: 12 cái sót sau một phiên). Waybar chạy nó qua "sh -c" nên cha bình thường là sh; cái mồ côi
    # bị gắn lại vào PID 1 hoặc systemd --user -> chỉ dọn những cái đó, trước khi bật waybar mới.
    for c in $(pgrep -u "$(id -u)" -f '^swaync-client -swb'); do
        pp=$(awk '/^PPid:/{print $2}' "/proc/$c/status" 2>/dev/null)
        { [ "$pp" = 1 ] || [ "$(cat "/proc/$pp/comm" 2>/dev/null)" = systemd ]; } && kill "$c" 2>/dev/null
    done
    waybar
    rc=$?
    case $rc in
        134 | 139) compositor_alive || exit 0; notify-send -u low "Waybar" "Waybar bị crash (mã $rc), đang khởi động lại"; sleep 1 ;;
        *) exit $rc ;;
    esac
done
