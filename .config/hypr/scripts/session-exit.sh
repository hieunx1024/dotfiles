#!/bin/bash
# Chạy 1 lần mỗi phiên Hyprland (exec-once). KHÔNG tắt tiến trình nào: dọn tiến trình của phiên là việc của
# systemd-logind (KillUserProcesses=yes) - nó biết chính xác tiến trình nào thuộc phiên nào. (03/10 bản cũ
# tự tắt tiến trình theo PID suy đoán; cùng thiết kế đó bên sway đã tắt nhầm cả phiên mới.)
# Script này chỉ lo phần DÙNG CHUNG giữa các phiên mà logind không quản, khi phiên này kết thúc:
#  - gỡ XMODIFIERS=@im=fcitx mà hyprland.conf export vào env systemd/dbus (Hyprland không tự gỡ): GNOME kế
#    tiếp dùng IBus, app XWayland nhận biến cũ -> tìm fcitx đã tắt -> không gõ được tiếng Việt;
#  - dừng portal/swaync (user service, nằm ngoài phiên): chỉ GNOME tự restart chúng -> phiên GNOME kế tiếp
#    nhận portal mang env Hyprland. Bỏ qua nếu còn phiên Wayland khác.
# Kích hoạt khi: phiên kết thúc - start-hyprland/GDM gửi HUP/TERM cho nhóm tiến trình Hyprland, logind
# đóng phiên (TERM) - hoặc Hyprland thoát (dự phòng, theo dõi qua cây tiến trình).
# DRY_RUN=1: chỉ in ra việc sẽ làm (để test).

LOG="${XDG_STATE_HOME:-$HOME/.local/state}/session-exit.log"; mkdir -p "$(dirname "$LOG")"
log() { echo "$(date '+%F %T') [Hyprland ${HYPR:-?}] $*" >> "$LOG"; }
run() {
    if [ -n "$DRY_RUN" ]; then echo "[dry-run] $*"; return; fi
    log "$*"; "$@"
}

# PID Hyprland: đi ngược cây tiến trình (exec-once chạy TRƯỚC khi Hyprland tạo hyprland.lock).
hypr_pid() {
    local p=$$
    while [ "${p:-1}" -gt 1 ] 2>/dev/null; do
        [ "$(cat "/proc/$p/comm" 2>/dev/null)" = Hyprland ] && { echo "$p"; return; }
        p=$(awk '/^PPid:/{print $2}' "/proc/$p/status" 2>/dev/null)
    done
}

other_sessions() {
    loginctl list-sessions --no-legend 2>/dev/null | awk -v u="$USER" '$3==u{print $1}' | while read -r s; do
        [ "$s" = "$XDG_SESSION_ID" ] && continue
        [ "$(loginctl show-session "$s" -p Type --value)" = wayland ] && [ "$(loginctl show-session "$s" -p State --value)" != closing ] && echo "$s"
    done
}

SERVICES="xdg-desktop-portal xdg-desktop-portal-hyprland xdg-desktop-portal-gtk swaync"
done_once=""
cleanup() {
    [ -n "$done_once" ] && return
    done_once=1
    trap '' TERM HUP INT
    [ -n "$SLEEP_PID" ] && kill "$SLEEP_PID" 2>/dev/null   # sleep chờ của chính script
    others=$(other_sessions)
    if [ -z "$others" ]; then
        if [ "$(systemctl --user show-environment | sed -n 's/^XMODIFIERS=//p')" = "@im=fcitx" ]; then
            run dbus-update-activation-environment XMODIFIERS=   # trước: dbus đồng bộ ngược sang systemd
            run systemctl --user unset-environment XMODIFIERS
        fi
        run systemctl --user stop $SERVICES
        # App đóng muộn có thể gọi portal/swaync lên lại trong khoảng trống giữa 2 phiên -> canh thêm 15s
        for _ in 1 2 3 4 5; do
            [ -n "$DRY_RUN" ] && break
            sleep 3
            [ -n "$(other_sessions)" ] && break
            for u in $SERVICES; do
                case "$(systemctl --user is-active "$u" 2>/dev/null)" in active|activating) run systemctl --user stop "$u" ;; esac
            done
        done
    else
        log "còn phiên khác ($others) - giữ nguyên service dùng chung"
    fi
    log "xong"
    exit 0
}
trap cleanup TERM HUP INT

HYPR=$(hypr_pid)
if [ -n "$HYPR" ]; then
    while [ "$(cat "/proc/$HYPR/comm" 2>/dev/null)" = Hyprland ]; do sleep 3 & SLEEP_PID=$!; wait "$SLEEP_PID"; done
    cleanup
else
    sleep infinity & SLEEP_PID=$!
    wait "$SLEEP_PID"
fi
