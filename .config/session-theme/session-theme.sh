#!/bin/bash
# =============================================================================
# GIAO DIỆN RIÊNG CHO TỪNG PHIÊN (sway / hyprland / kde / gnome)
# gsettings (dconf) là kho chung duy nhất cho theme GTK, icon, cursor, font -> phiên nào
# đổi cũng lan sang phiên khác. Script này chạy lúc đăng nhập mỗi phiên:
#   1. Cất giá trị đang có trong dconf vào snapshot của phiên TRƯỚC (giữ lại mọi thay đổi
#      người dùng đã làm trong phiên đó)
#   2. Nạp snapshot của phiên HIỆN TẠI (lần đầu lấy từ defaults/<phiên>.conf)
# Dùng: session-theme.sh <sway|hyprland|kde|gnome>
# (03/10: Hyprland từng không tham gia -> theme-selector của Hyprland ghi gsettings, phiên kế tiếp
#  cất nhầm giá trị đó vào snapshot của phiên trước -> GNOME bị đổi icon/theme.)
# =============================================================================

SESSION="$1"
case "$SESSION" in
    sway|hyprland|kde|gnome) ;;
    *) echo "Dùng: $0 <sway|hyprland|kde|gnome>" >&2; exit 1 ;;
esac

DIR="$(dirname "$(readlink -f "$0")")"
STATE="${XDG_STATE_HOME:-$HOME/.local/state}/session-theme"
mkdir -p "$STATE"

# Các key giao diện được tách theo phiên: "<schema> <key>"
KEYS=(
    "org.gnome.desktop.interface gtk-theme"
    "org.gnome.desktop.interface icon-theme"
    "org.gnome.desktop.interface cursor-theme"
    "org.gnome.desktop.interface cursor-size"
    "org.gnome.desktop.interface font-name"
    "org.gnome.desktop.interface document-font-name"
    "org.gnome.desktop.interface monospace-font-name"
    "org.gnome.desktop.interface color-scheme"
    "org.gnome.desktop.interface accent-color"
    "org.gnome.desktop.wm.preferences button-layout"
)

save_snapshot() {
    local out="$1" k tmp
    tmp="$(mktemp "$STATE/.tmp.XXXXXX")" || return 1
    for k in "${KEYS[@]}"; do
        # shellcheck disable=SC2086
        echo "$k $(gsettings get $k 2>/dev/null)" >> "$tmp"
    done
    mv "$tmp" "$out"
}

load_snapshot() {
    local schema key value
    while read -r schema key value; do
        [ -z "$schema" ] || [ "${schema:0:1}" = "#" ] || [ -z "$value" ] && continue
        gsettings set "$schema" "$key" "$value" 2>/dev/null
    done < "$1"
}

LAST="$(cat "$STATE/last" 2>/dev/null)"
[ -n "$LAST" ] && save_snapshot "$STATE/$LAST.conf"

if [ -f "$STATE/$SESSION.conf" ]; then
    load_snapshot "$STATE/$SESSION.conf"
else
    load_snapshot "$DIR/defaults/$SESSION.conf"
fi
echo "$SESSION" > "$STATE/last"

# Sway: áp cursor cho chính compositor (XCURSOR_THEME/XCURSOR_SIZE của các app con)
if [ "$SESSION" = "sway" ] && [ -n "$SWAYSOCK" ]; then
    cursor="$(gsettings get org.gnome.desktop.interface cursor-theme | tr -d "'")"
    size="$(gsettings get org.gnome.desktop.interface cursor-size)"
    swaymsg seat seat0 xcursor_theme "$cursor" "${size:-24}" >/dev/null
fi
