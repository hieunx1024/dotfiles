#!/bin/bash
# Script quản lý & chọn chế độ hiệu năng (Performance, Balanced, Power Saver)
# Kiểm soát phần cứng: Tắt/Bật Turbo Boost, khóa trần xung nhịp & tự động điều tiết thông minh
export PATH="$HOME/.local/bin:$PATH"

BOOST_FILE="/sys/devices/system/cpu/cpufreq/boost"
STATE_FILE="$HOME/.config/sway/current_power_mode"

# Cấu hình giới hạn xung nhịp phần cứng (kHz):
# - Performance: Mở hết công suất phần cứng (tối đa 4.4 GHz), cơ chế điều tiết tự động giống Balanced cũ
# - Balanced: Khóa trần ở 3.4 GHz (hoặc 3.2 GHz Base Clock) giúp máy luôn mát mẻ & quạt êm ru
# - Power Saver: Khóa trần ở 2.0 GHz, tắt Turbo Boost giúp tiết kiệm pin tối đa
HW_MAX_FREQ=$(cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq 2>/dev/null || echo 4465261)
BALANCED_MAX_FREQ=3200000      # 3.2 GHz (Base Clock chuẩn Ryzen 7 5800H)
POWER_SAVER_MAX_FREQ=2000000   # 2.0 GHz

# Tính chuỗi GHz hiển thị cho Balanced (3.4 hoặc 3.2)
BALANCED_FREQ_GHZ=$(awk "BEGIN {printf \"%.1f\", $BALANCED_MAX_FREQ / 1000000}")

get_current() {
    if [ -f "$STATE_FILE" ]; then
        local saved
        saved=$(cat "$STATE_FILE" 2>/dev/null)
        case "$saved" in
            performance|balanced|power-saver)
                echo "$saved"
                return
                ;;
        esac
    fi

    # Fallback nếu chưa có state file: kiểm tra qua hardware scaling_max_freq & powerprofilesctl
    local pctl
    pctl=$(powerprofilesctl get 2>/dev/null || echo "balanced")
    if [ "$pctl" = "power-saver" ]; then
        echo "power-saver"
    else
        local cur_max
        cur_max=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq 2>/dev/null || echo 0)
        if [ "$cur_max" -gt 3500000 ]; then
            echo "performance"
        else
            echo "balanced"
        fi
    fi
}

apply_hardware_limits() {
    local target="$1"
    local expected_max
    local expected_boost

    case "$target" in
        "power-saver")
            expected_max="$POWER_SAVER_MAX_FREQ"
            expected_boost=0
            ;;
        "balanced")
            expected_max="$BALANCED_MAX_FREQ"
            expected_boost=1
            ;;
        "performance")
            # Perf mode: giống Balanced mode cũ (mở tối đa 4.4 GHz, tự điều tiết thông minh khi nhẹ)
            expected_max="$HW_MAX_FREQ"
            expected_boost=1
            ;;
        *)
            expected_max="$BALANCED_MAX_FREQ"
            expected_boost=1
            ;;
    esac

    # 1. Điều khiển Turbo Boost
    if [ -w "$BOOST_FILE" ]; then
        local cur_boost
        cur_boost=$(cat "$BOOST_FILE" 2>/dev/null)
        if [ "$cur_boost" != "$expected_boost" ]; then
            echo "$expected_boost" > "$BOOST_FILE" 2>/dev/null
        fi
    fi

    # 2. Khóa trần xung nhịp (scaling_max_freq)
    local cur_max
    cur_max=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq 2>/dev/null)
    if [ "$cur_max" != "$expected_max" ]; then
        for f in /sys/devices/system/cpu/cpu*/cpufreq/scaling_max_freq; do
            [ -w "$f" ] && echo "$expected_max" > "$f" 2>/dev/null
        done
    fi
}

set_profile() {
    local target="$1"

    # Lưu trạng thái mode
    echo "$target" > "$STATE_FILE" 2>/dev/null

    # Cấu hình qua powerprofilesctl:
    # - power-saver: dùng profile power-saver của daemon
    # - balanced và performance: đều dùng profile balanced của daemon để CPU dùng EPP balance_performance
    #   (điều tiết linh hoạt, khi nhẹ hạ về 1.1 GHz êm ái, khi nặng bung xung; khác biệt là trần xung nhịp do apply_hardware_limits quản lý)
    if [ "$target" = "power-saver" ]; then
        powerprofilesctl set power-saver 2>/dev/null
    else
        # Mở global boost trước để tránh lỗi EINVAL
        if [ -w "$BOOST_FILE" ]; then
            echo 1 > "$BOOST_FILE" 2>/dev/null
        fi
        powerprofilesctl set balanced 2>/dev/null
    fi

    apply_hardware_limits "$target"

    # Gửi tín hiệu SIGRTMIN+2 để Waybar cập nhật ngay lập tức
    pkill -RTMIN+2 waybar 2>/dev/null

    case "$target" in
        "performance")
            notify-send -t 1500 -h string:x-canonical-private-synchronous:power \
                -i "battery-charging" "Chế độ Hiệu năng" "Đã chuyển sang: Performance (Mở tối đa 4.4GHz, Tự động điều tiết) 󱐋"
            ;;
        "balanced")
            notify-send -t 1500 -h string:x-canonical-private-synchronous:power \
                -i "battery" "Chế độ Hiệu năng" "Đã chuyển sang: Balanced (Khóa trần ${BALANCED_FREQ_GHZ}GHz, Mát mẻ & Quạt êm) 󰾆"
            ;;
        "power-saver")
            notify-send -t 1500 -h string:x-canonical-private-synchronous:power \
                -i "battery-low" "Chế độ Hiệu năng" "Đã chuyển sang: Power Saver (Khóa trần 2.0GHz, Tắt Turbo Boost) 󱊢"
            ;;
    esac
}

case "$1" in
    --status)
        current=$(get_current)
        # Đảm bảo phần cứng luôn đúng giới hạn (tự phục hồi sau reboot / suspend)
        apply_hardware_limits "$current"

        case "$current" in
            performance)
                icon="󱐋"
                desc="Performance (Hiệu năng cao)"
                freq_info="\n⚡ Xung nhịp: Mở tối đa 4.4 GHz (Giống Balanced cũ, tự điều tiết)"
                ;;
            power-saver)
                icon="󱊢"
                desc="Power Saver (Tiết kiệm pin)"
                freq_info="\n⚡ Xung nhịp: Khóa trần 2.0 GHz (Tắt Turbo Boost)"
                ;;
            *)
                icon="󰾆"
                desc="Balanced (Cân bằng)"
                current="balanced"
                freq_info="\n⚡ Xung nhịp: Khóa trần ${BALANCED_FREQ_GHZ} GHz (Êm ái & Mát mẻ)"
                ;;
        esac

        # In JSON cho Waybar
        printf '{"text":"%s","alt":"%s","class":"%s","tooltip":"Chế độ: %s%s\\n\\n• Chuột trái: Chuyển nhanh chế độ kế tiếp\\n• Chuột phải: Mở menu chọn trực tiếp"}\n' \
            "$icon" "$current" "$current" "$desc" "$freq_info"
        ;;

    --next)
        current=$(get_current)
        case "$current" in
            performance)
                set_profile "balanced"
                ;;
            balanced)
                set_profile "power-saver"
                ;;
            power-saver|*)
                set_profile "performance"
                ;;
        esac
        ;;

    --prev)
        current=$(get_current)
        case "$current" in
            performance)
                set_profile "power-saver"
                ;;
            balanced)
                set_profile "performance"
                ;;
            power-saver|*)
                set_profile "balanced"
                ;;
        esac
        ;;

    --menu|*)
        current=$(get_current)
        choice=$(printf "󱐋  Performance   (Mở tối đa 4.4GHz, Tự động điều tiết)\n󰾆  Balanced      (Khóa trần ${BALANCED_FREQ_GHZ}GHz, Mát mẻ & Êm ái)\n󱊢  Power Saver   (Khóa trần 2.0GHz, Tắt Boost)" | \
            fuzzel -d -w 52 -l 3 -p "󱐋 Power Mode ($current) ❯ ")

        case "$choice" in
            *"Performance"*)
                set_profile "performance"
                ;;
            *"Balanced"*)
                set_profile "balanced"
                ;;
            *"Power Saver"*)
                set_profile "power-saver"
                ;;
        esac
        ;;
esac
