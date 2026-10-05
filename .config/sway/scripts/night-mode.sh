#!/bin/bash
# =============================================================================
# NIGHT LIGHT (BLUE LIGHT FILTER) CONTROLLER FOR SWAY
# Supports: Toggle, Fuzzel Menu, Temperature Adjustment (+/- 500K)
# =============================================================================

STATE_FILE="$HOME/.config/sway/nightlight_temp"

# Check if wlsunset is installed
if ! command -v wlsunset &> /dev/null; then
    notify-send "Night Light" "wlsunset is not installed. Please install it with your package manager (apt/dnf/pacman)." -u critical
    exit 1
fi

get_saved_temp() {
    if [ -f "$STATE_FILE" ]; then
        local saved
        saved=$(cat "$STATE_FILE" 2>/dev/null)
        if [[ "$saved" =~ ^[0-9]+$ ]] && [ "$saved" -ge 1000 ] && [ "$saved" -le 10000 ]; then
            echo "$saved"
            return
        fi
    fi
    echo 4500
}

start_nightlight() {
    local temp="$1"
    pkill -x wlsunset 2>/dev/null
    # -t and -T set to nearly same values forces the temperature immediately
    wlsunset -t "$temp" -T "$((temp + 1))" >/dev/null 2>&1 &
    echo "$temp" > "$STATE_FILE"
    notify-send -h string:x-canonical-private-synchronous:nightlight \
        -i display-brightness-symbolic "Night Light" "Đã bật lọc ánh sáng xanh (${temp}K) 󰖔"
    pkill -RTMIN+1 waybar 2>/dev/null
}

stop_nightlight() {
    pkill -x wlsunset 2>/dev/null
    notify-send -h string:x-canonical-private-synchronous:nightlight \
        -i display-brightness-symbolic "Night Light" "Đã tắt lọc ánh sáng xanh 󰃠"
    pkill -RTMIN+1 waybar 2>/dev/null
}

toggle_nightlight() {
    if pgrep -x "wlsunset" > /dev/null; then
        stop_nightlight
    else
        local temp
        temp=$(get_saved_temp)
        start_nightlight "$temp"
    fi
}

show_menu() {
    local current_temp
    current_temp=$(get_saved_temp)
    local is_running=false
    if pgrep -x "wlsunset" > /dev/null; then
        is_running=true
    fi

    local temps=(6000 5500 5000 4500 4000 3500 3000 2500)
    local labels=("Dịu nhẹ" "Tự nhiên" "Tiêu chuẩn" "Ấm dịu (Chuẩn)" "Vàng ấm" "Đêm khuya" "Rất ấm" "Siêu ấm")
    local items=()

    for i in "${!temps[@]}"; do
        local t="${temps[$i]}"
        local l="${labels[$i]}"
        if [ "$is_running" = true ] && [ "$t" = "$current_temp" ]; then
            items+=("✓ 󰖔 ${t}K  $l")
        else
            items+=("  󰖔 ${t}K  $l")
        fi
    done

    if [ "$is_running" = false ]; then
        items+=("✓ 󰃠 Tắt Night Light")
    else
        items+=("  󰃠 Tắt Night Light")
    fi

    items+=("  󰅖 Đóng menu")

    local choice
    choice=$(printf "%s\n" "${items[@]}" | fuzzel -d \
        -a bottom-right \
        --x-margin=190 \
        --y-margin=32 \
        -w 22 \
        -l 10 \
        -p "󰖔 " \
        --placeholder="Nhiệt độ..." \
        --no-exit-on-keyboard-focus-loss)

    [ -z "$choice" ] && exit 0
    [[ "$choice" == *"Đóng"* ]] && exit 0

    if [[ "$choice" == *"Tắt"* ]]; then
        stop_nightlight
    else
        local selected_temp
        selected_temp=$(echo "$choice" | grep -oE '[0-9]{4}')
        if [ -n "$selected_temp" ]; then
            start_nightlight "$selected_temp"
        fi
    fi
}

adjust_temp() {
    local delta="$1"
    local current_temp
    current_temp=$(get_saved_temp)
    local new_temp=$((current_temp + delta))

    if [ "$new_temp" -gt 6500 ]; then
        new_temp=6500
    elif [ "$new_temp" -lt 2000 ]; then
        new_temp=2000
    fi

    if pgrep -x "wlsunset" > /dev/null; then
        start_nightlight "$new_temp"
    else
        echo "$new_temp" > "$STATE_FILE"
        notify-send -h string:x-canonical-private-synchronous:nightlight \
            -i display-brightness-symbolic "Night Light" "Đã đặt nhiệt độ màu: ${new_temp}K (Hiện đang tắt)"
        pkill -RTMIN+1 waybar 2>/dev/null
    fi
}

case "$1" in
    --menu)
        show_menu
        ;;
    --toggle)
        toggle_nightlight
        ;;
    --on)
        temp="${2:-$(get_saved_temp)}"
        start_nightlight "$temp"
        ;;
    --off)
        stop_nightlight
        ;;
    --set)
        if [[ "$2" =~ ^[0-9]+$ ]] && [ "$2" -ge 1000 ] && [ "$2" -le 10000 ]; then
            start_nightlight "$2"
        else
            echo "Usage: $0 --set <temperature_in_kelvin>" >&2
            exit 1
        fi
        ;;
    --up)
        adjust_temp 500
        ;;
    --down)
        adjust_temp -500
        ;;
    *)
        toggle_nightlight
        ;;
esac
