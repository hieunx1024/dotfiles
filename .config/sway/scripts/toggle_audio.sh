#!/bin/bash

CARD="alsa_card.pci-0000_07_00.6"
PROFILE_HP="HiFi (Headphones, Mic1, Mic2)"
PROFILE_SPK="HiFi (Mic1, Mic2, Speaker)"

# 1. Kiểm tra trạng thái tai nghe
WIRED_AVAILABLE=false
if ! pactl list cards | grep -A 50 "$CARD" | grep "Headphones: Headphones" | grep -q "not available"; then
    WIRED_AVAILABLE=true
fi

BT_SINK=$(pactl list sinks short | awk '{print $2}' | grep "bluez_output" | head -n 1)
BT_AVAILABLE=false
if [ -n "$BT_SINK" ]; then
    BT_AVAILABLE=true
fi

# 2. Xử lý logic
if [ "$WIRED_AVAILABLE" = false ] && [ "$BT_AVAILABLE" = false ]; then
    # Không có tai nghe nào được kết nối
    pactl set-card-profile "$CARD" "$PROFILE_SPK"
    pactl set-default-sink "alsa_output.pci-0000_07_00.6.HiFi__Speaker__sink" 2>/dev/null
    notify-send "Audio Output" "Không có tai nghe nào được kết nối!\nĐang sử dụng Loa Laptop." -i audio-speakers
    exit 0
fi

# Lấy profile hiện tại của ALSA card
CURRENT_PROFILE=$(pactl list cards | grep -A 40 "$CARD" | grep "Active Profile:" | cut -d ':' -f 2 | xargs)
# Lấy sink mặc định hiện tại
DEFAULT_SINK=$(pactl info | grep "Default Sink" | awk '{print $3}')

# Xác định xem hiện tại có đang dùng Loa Laptop hay không
IS_SPEAKER=false
if [ "$CURRENT_PROFILE" = "$PROFILE_SPK" ] && [[ "$DEFAULT_SINK" != *"bluez"* ]]; then
    IS_SPEAKER=true
fi

if [ "$IS_SPEAKER" = true ]; then
    # Đang là loa -> chuyển sang tai nghe
    if [ "$BT_AVAILABLE" = true ]; then
        pactl set-default-sink "$BT_SINK"
        notify-send "Audio Output" "Đã chuyển sang Tai nghe Bluetooth" -i audio-headphones
    else
        pactl set-card-profile "$CARD" "$PROFILE_HP"
        pactl set-default-sink "alsa_output.pci-0000_07_00.6.HiFi__Headphones__sink" 2>/dev/null
        notify-send "Audio Output" "Đã chuyển sang Tai nghe dây" -i audio-headphones
    fi
else
    # Đang là tai nghe -> chuyển sang loa
    pactl set-card-profile "$CARD" "$PROFILE_SPK"
    pactl set-default-sink "alsa_output.pci-0000_07_00.6.HiFi__Speaker__sink" 2>/dev/null
    notify-send "Audio Output" "Đã chuyển sang Loa Laptop" -i audio-speakers
fi

