#!/bin/bash
# Super+Shift+P: chọn chế độ hiển thị laptop + màn ngoài (bản Hyprland của sway/scripts/display-mode.sh).
# Chạy không tham số -> menu fuzzel; hoặc truyền thẳng chế độ:
#   laptop | external | right | left | above | mirror
# Đổi bằng `hyprctl keyword monitor` nên chỉ có hiệu lực tới lần reload/đăng nhập sau
# (các dòng monitor= trong hyprland.conf được áp lại) - giống `reload` bên sway.
# Không lưu lại chế độ: rút màn ngoài khi đang "chỉ màn ngoài" sẽ không để laptop tối đen.

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

notify() { notify-send -h string:x-canonical-private-synchronous:display-mode "Cấu hình Màn hình" "$1"; }

MONITORS=$(hyprctl monitors all -j)
PRIMARY=$(jq -r '[.[] | select(.name | test("^(eDP|LVDS|DSI)"))][0].name // empty' <<<"$MONITORS")
[ -z "$PRIMARY" ] && PRIMARY=$(jq -r '.[0].name' <<<"$MONITORS")
SECONDARY=$(jq -r --arg p "$PRIMARY" '[.[] | select(.name != $p)][0].name // empty' <<<"$MONITORS")

if [ -z "$SECONDARY" ]; then
    notify "Không tìm thấy màn hình ngoài nào được kết nối!"
    hyprctl keyword monitor "$PRIMARY, preferred, 0x0, 1" >/dev/null
    exit 1
fi

# Mode cho từng màn: đang bật -> giữ mode hiện tại; đang tắt -> độ phân giải lớn nhất rồi tần số
# cao nhất trong availableModes ("preferred" của HDMI là 60Hz, sẽ mất 100Hz).
# Kích thước logic = pixel / scale, dùng để tính vị trí đặt màn.
mode_of() {
    jq -r --arg n "$1" '.[] | select(.name == $n) |
        if (.disabled | not) and .width > 0 then "\(.width)x\(.height)@\(.refreshRate)"
        else ([.availableModes[] | capture("^(?<w>[0-9]+)x(?<h>[0-9]+)@(?<r>[0-9.]+)")
               | {w: (.w|tonumber), h: (.h|tonumber), r: (.r|tonumber)}]
              | max_by([.w * .h, .r]) // null
              | if . == null then "preferred" else "\(.w)x\(.h)@\(.r)" end) end' <<<"$MONITORS"
}
logical() { # $1 tên màn, $2 width|height
    jq -r --arg n "$1" --arg k "$2" '.[] | select(.name == $n) |
        if .width == 0 then 1920 * (if $k == "height" then 9/16 else 1 end)
        else (.[$k] / .scale) end | floor' <<<"$MONITORS"
}
P_MODE=$(mode_of "$PRIMARY");   S_MODE=$(mode_of "$SECONDARY")
P_W=$(logical "$PRIMARY" width)
S_W=$(logical "$SECONDARY" width); S_H=$(logical "$SECONDARY" height)

CHOICE=$1
if [ -z "$CHOICE" ]; then
    OPTIONS="󰌢  Chỉ màn hình laptop     (Tắt màn hình ngoài)
󰍹  Chỉ màn hình ngoài      (Tắt màn hình laptop)
󰍺  Mở rộng sang phải       (Laptop ← | → Màn ngoài)
󰍺  Mở rộng sang trái       (Màn ngoài ← | → Laptop)
󰍺  Mở rộng lên trên        (Màn ngoài ↑ / ↓ Laptop)
󰍻  Phản chiếu màn hình     (Nhân bản Mirror)"
    CHOICE=$(fuzzel -d -w 52 -l 6 -p "󰍹 Display Mode ❯ " <<<"$OPTIONS") || exit 0
fi

# Bật màn cần dùng trước rồi mới tắt màn kia (một batch) để không có lúc không màn nào sáng;
# workspace của màn bị tắt được Hyprland tự chuyển sang màn còn lại.
case "$CHOICE" in
    laptop | *"Chỉ màn hình laptop"*)
        hyprctl --batch "keyword monitor $PRIMARY, $P_MODE, 0x0, 1 ; keyword monitor $SECONDARY, disable"
        notify "Chỉ dùng màn hình laptop ($PRIMARY)" ;;
    external | *"Chỉ màn hình ngoài"*)
        hyprctl --batch "keyword monitor $SECONDARY, $S_MODE, 0x0, 1 ; keyword monitor $PRIMARY, disable"
        notify "Chỉ dùng màn ngoài ($SECONDARY), đã tắt màn laptop" ;;
    right | *"Mở rộng sang phải"*)
        hyprctl --batch "keyword monitor $PRIMARY, $P_MODE, 0x0, 1 ; keyword monitor $SECONDARY, $S_MODE, ${P_W}x0, 1"
        notify "Mở rộng: laptop bên TRÁI, màn ngoài bên PHẢI" ;;
    left | *"Mở rộng sang trái"*)
        hyprctl --batch "keyword monitor $SECONDARY, $S_MODE, 0x0, 1 ; keyword monitor $PRIMARY, $P_MODE, ${S_W}x0, 1"
        notify "Mở rộng: màn ngoài bên TRÁI, laptop bên PHẢI" ;;
    above | *"Mở rộng lên trên"*)
        hyprctl --batch "keyword monitor $SECONDARY, $S_MODE, 0x0, 1 ; keyword monitor $PRIMARY, $P_MODE, 0x${S_H}, 1"
        notify "Mở rộng: màn ngoài ở TRÊN, laptop ở DƯỚI" ;;
    mirror | *"Phản chiếu màn hình"*)
        # Hyprland mirror sẵn, không cần wl-mirror như bên sway
        hyprctl --batch "keyword monitor $PRIMARY, $P_MODE, 0x0, 1 ; keyword monitor $SECONDARY, $S_MODE, auto, 1, mirror, $PRIMARY"
        notify "Phản chiếu màn laptop ($PRIMARY) sang $SECONDARY" ;;
    *)
        echo "Chế độ không hợp lệ: $CHOICE (laptop|external|right|left|above|mirror)" >&2
        exit 1 ;;
esac

# Floating scratchpad giữ tọa độ tuyệt đối khi monitor bị tắt; đặt lại vào giữa màn còn bật.
sleep 0.35
"$SCRIPT_DIR/recenter-scratchpads.sh"
