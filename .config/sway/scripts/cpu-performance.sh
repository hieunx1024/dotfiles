#!/bin/bash

# Function to get status
get_status() {
    gov=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)
    
    # Lấy xung nhịp hiện tại (đổi từ kHz sang GHz)
    freq_khz=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq)
    freq_ghz=$(awk "BEGIN {printf \"%.2f\", $freq_khz/1000000}")
    
    sensors_out=$(sensors 2>/dev/null)
    temp=$(echo "$sensors_out" | grep Tctl | awk '{print $2}')
    power=$(echo "$sensors_out" | grep -A 10 "amdgpu-pci-0700" | grep PPT | awk '{print $2}')
    
    if [ "$gov" = "performance" ]; then
        text=""
        gov_vn="Hiệu năng"
    else
        text=""
        gov_vn="Tiết kiệm"
    fi
    
    echo "{\"text\": \"$text\", \"tooltip\": \"$gov_vn\\n󰓅 ${freq_ghz} GHz\\n$temp\\n⚡ ${power}W\"}"
}

# Function to show menu
toggle_mode() {
    gov=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)
    if [ "$gov" = "performance" ]; then
        sudo cpupower frequency-set -g powersave
    else
        sudo cpupower frequency-set -g performance
    fi
}

case "$1" in
    status)
        get_status
        ;;
    toggle)
        toggle_mode
        ;;
    *)
        get_status
        ;;
esac
