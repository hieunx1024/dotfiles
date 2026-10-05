#!/bin/bash
# Chạy 1 lần lúc đăng nhập sway (exec): sau 15s kiểm tra còn tiến trình nền nào SÓT LẠI từ phiên
# trước (sway/Hyprland/GNOME) mà session-exit.sh lẽ ra phải dọn - nằm trong session-*.scope KHÁC
# phiên này (cả app, vd IntelliJ chạy ngầm). Có thì báo + ghi log; sạch thì im lặng. Chỉ đọc, không tắt gì. Log: ~/.local/state/session-check.log
sleep 15
LOG="${XDG_STATE_HOME:-$HOME/.local/state}/session-check.log"; mkdir -p "$(dirname "$LOG")"
MY_SCOPE=$(cut -d: -f3 /proc/self/cgroup)
# Tiến trình còn trong phiên CŨ (logind đang đóng phiên đó - state closing, hoặc logind đã quên). Phiên khác
# đang thật sự dùng (active/online, vd TTY) không tính. Tiến trình GDM sống tới cuối phiên, không tính.
collect() {
    for pid in $(pgrep -u "$(id -u)"); do
        scope=$(cut -d: -f3 "/proc/$pid/cgroup" 2>/dev/null) || continue
        case "$scope" in */session-*.scope) ;; *) continue ;; esac
        [ "$scope" = "$MY_SCOPE" ] && continue
        sid=${scope##*/session-}; sid=${sid%.scope}
        case "$(loginctl show-session "$sid" -p State --value 2>/dev/null)" in active|online) continue ;; esac
        comm=$(cat "/proc/$pid/comm" 2>/dev/null) || continue
        case "$comm" in gdm-*) continue ;; esac
        printf '\n  %s %s %s %s' "$pid" "${scope##*/}" "$comm" "$(tr '\0' ' ' < "/proc/$pid/cmdline" 2>/dev/null | cut -c1-70)"
    done
}
# KillUserProcesses: logind gửi TERM cho phiên cũ, app nào lì (vd jetbrainsd) bị KILL sau 90s. Chờ logind
# làm xong (tối đa 120s) rồi mới kết luận - 03/10 báo nhầm jetbrainsd khi logind còn đang dọn.
found=$(collect)
for _ in $(seq 1 12); do
    [ -z "$found" ] && break
    sleep 10
    found=$(collect)
done
if [ -n "$found" ]; then
    printf '%s phiên %s: SÓT LẠI từ phiên cũ (sau khi chờ logind dọn):%s\n' "$(date '+%F %T')" "${MY_SCOPE##*/}" "$found" >> "$LOG"
    notify-send -u critical "Kiểm tra phiên" "Còn tiến trình sót từ phiên trước - xem $LOG"
else
    echo "$(date '+%F %T') phiên ${MY_SCOPE##*/}: sạch" >> "$LOG"
fi
