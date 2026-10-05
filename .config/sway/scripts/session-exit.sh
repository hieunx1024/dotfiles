#!/bin/bash
# Chạy 1 lần mỗi phiên sway (exec). KHÔNG tắt tiến trình nào: dọn tiến trình của phiên là việc của
# systemd-logind (KillUserProcesses=yes trong /etc/systemd/logind.conf.d/) - nó biết chính xác tiến trình
# nào thuộc phiên nào, không thể nhầm sang phiên mới. (03/10 bản cũ tự tắt tiến trình, suy PID sway từ tên
# SWAYSOCK sót lại -> tắt nhầm cả phiên sway mới.)
# Script này chỉ lo phần DÙNG CHUNG giữa các phiên mà logind không quản, khi phiên này kết thúc:
#  - gỡ SWAYSOCK của chính phiên khỏi env systemd/dbus: GDM truyền env đó cho phiên kế tiếp, sway mới dùng
#    lại đường dẫn cũ làm socket, công cụ khác tưởng vẫn còn sway cũ;
#  - dừng portal/swaync (user service, nằm ngoài phiên): chỉ GNOME tự restart chúng, sway/Hyprland
#    thì không -> phiên GNOME kế tiếp nhận portal mang env sway. Bỏ qua nếu còn phiên Wayland khác.
# Kích hoạt khi: logind đóng phiên (gửi TERM/HUP cho script này), hoặc sway thoát (dự phòng).
# DRY_RUN=1: chỉ in ra việc sẽ làm (để test).

LOG="${XDG_STATE_HOME:-$HOME/.local/state}/session-exit.log"; mkdir -p "$(dirname "$LOG")"
log() { echo "$(date '+%F %T') [sway ${SWAY:-?}] $*" >> "$LOG"; }
run() {
    if [ -n "$DRY_RUN" ]; then echo "[dry-run] $*"; return; fi
    log "$*"; "$@"
}

# PID sway: đi ngược cây tiến trình (exec của sway là con trực tiếp); không thấy thì hỏi ai giữ $SWAYSOCK.
# Không suy từ tên socket (số trong tên có thể là PID sway cũ - xem trên).
sway_pid() {
    local p=$$
    while [ "${p:-1}" -gt 1 ] 2>/dev/null; do
        [ "$(cat "/proc/$p/comm" 2>/dev/null)" = sway ] && { echo "$p"; return; }
        p=$(awk '/^PPid:/{print $2}' "/proc/$p/status" 2>/dev/null)
    done
    [ -n "$SWAYSOCK" ] && ss -xlpH 2>/dev/null | awk -v s="$SWAYSOCK" '$5==s' | grep -oE 'pid=[0-9]+' | head -1 | cut -d= -f2
}

# Phiên Wayland khác của user đang chạy (đã đăng nhập lại) -> không đụng service dùng chung.
other_sessions() {
    loginctl list-sessions --no-legend 2>/dev/null | awk -v u="$USER" '$3==u{print $1}' | while read -r s; do
        [ "$s" = "$XDG_SESSION_ID" ] && continue
        [ "$(loginctl show-session "$s" -p Type --value)" = wayland ] && [ "$(loginctl show-session "$s" -p State --value)" != closing ] && echo "$s"
    done
}

SERVICES="xdg-desktop-portal xdg-desktop-portal-wlr xdg-desktop-portal-gtk swaync"
done_once=""
cleanup() {
    [ -n "$done_once" ] && return
    done_once=1
    trap '' TERM HUP INT
    [ -n "$SLEEP_PID" ] && kill "$SLEEP_PID" 2>/dev/null   # sleep chờ của chính script
    if [ -n "$SWAYSOCK" ] && [ "$(systemctl --user show-environment | sed -n 's/^SWAYSOCK=//p')" = "$SWAYSOCK" ]; then
        run dbus-update-activation-environment SWAYSOCK=   # trước: dbus đồng bộ ngược sang systemd
        run systemctl --user unset-environment SWAYSOCK
    fi
    others=$(other_sessions)
    if [ -z "$others" ]; then
        run systemctl --user stop $SERVICES
        # App đóng muộn có thể gọi portal/swaync lên lại trong khoảng trống giữa 2 phiên (03/10: IntelliJ
        # làm portal treo 90s ở phiên GNOME sau) -> canh thêm 15s, dừng lại nếu chưa có phiên mới.
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

SWAY=$(sway_pid)
if [ -n "$SWAY" ] && [ "$(cat "/proc/$SWAY/comm" 2>/dev/null)" = sway ]; then
    while [ "$(cat "/proc/$SWAY/comm" 2>/dev/null)" = sway ]; do sleep 3 & SLEEP_PID=$!; wait "$SLEEP_PID"; done
    cleanup
else
    # Không xác định được sway -> chỉ chờ logind đóng phiên (TERM/HUP) rồi dọn
    SWAY=""
    sleep infinity & SLEEP_PID=$!
    wait "$SLEEP_PID"
fi
