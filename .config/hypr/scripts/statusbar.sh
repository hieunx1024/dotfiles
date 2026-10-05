#!/bin/bash
# (Tên file cố ý không chứa "waybar": các bind `pkill -USR1/-RTMIN+1 waybar` khớp theo tên
# tiến trình, script tên waybar.sh sẽ nhận nhầm tín hiệu và bash chết theo.)
# Chạy waybar, tự bật lại nếu nó crash. waybar 0.15 segfault trong module mpris
# (Glib::Dispatcher khi libplayerctl báo player mới) -> mất thanh bar giữa chừng.
# Chỉ restart khi chết vì SIGSEGV(139)/SIGABRT(134); pkill/thoát thường thì dừng hẳn.
# Compositor đã chết (logout/crash) thì không restart nữa - tránh vòng lặp mỗi giây khi không còn màn hình
# PID Hyprland: đi ngược cây tiến trình (exec-once chạy TRƯỚC khi Hyprland tạo hyprland.lock, nên
# đọc lock lúc khởi động sẽ rỗng); không thấy mới đọc lock.
hypr_pid() {
    local p=$$
    while [ "${p:-1}" -gt 1 ] 2>/dev/null; do
        [ "$(cat "/proc/$p/comm" 2>/dev/null)" = Hyprland ] && { echo "$p"; return; }
        p=$(awk '/^PPid:/{print $2}' "/proc/$p/status" 2>/dev/null)
    done
    head -1 "${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/hypr/$HYPRLAND_INSTANCE_SIGNATURE/hyprland.lock" 2>/dev/null
}
COMP_PID=$(hypr_pid); COMP_NAME=Hyprland
compositor_alive() { [ -z "$COMP_PID" ] || [ "$(cat "/proc/$COMP_PID/comm" 2>/dev/null)" = "$COMP_NAME" ]; }
while true; do
    # waybar sinh "swaync-client -swb" cho module thông báo; waybar bị tắt/crash thì nó mồ côi và tích tụ
    # (03/10: 12 cái sót sau một phiên). Waybar chạy nó qua "sh -c" nên cha bình thường là sh; cái mồ côi
    # bị gắn lại vào PID 1 hoặc systemd --user -> chỉ dọn những cái đó, trước khi bật waybar mới.
    for c in $(pgrep -u "$(id -u)" -f '^swaync-client -swb'); do
        pp=$(awk '/^PPid:/{print $2}' "/proc/$c/status" 2>/dev/null)
        { [ "$pp" = 1 ] || [ "$(cat "/proc/$pp/comm" 2>/dev/null)" = systemd ]; } && kill "$c" 2>/dev/null
    done
    waybar -c ~/.config/hypr/waybar/config.jsonc -s ~/.config/hypr/waybar/style.css
    rc=$?
    case $rc in
        134 | 139) compositor_alive || exit 0; notify-send -u low "Waybar" "Waybar bị crash (mã $rc), đang khởi động lại"; sleep 1 ;;
        *) exit $rc ;;
    esac
done
