#!/bin/bash

CARD="alsa_card.pci-0000_07_00.6"
PROFILE1="HiFi (Headphones, Mic1, Mic2)"
PROFILE2="HiFi (Mic1, Mic2, Speaker)"

# Lấy dòng chứa thông tin Headphones
HP_LINE=$(pactl list cards | grep -A 50 "$CARD" | grep "Headphones: Headphones")

if echo "$HP_LINE" | grep -q "not available"; then
    # Tai nghe không cắm
    CURRENT_PROFILE=$(pactl list cards | grep -A 40 "$CARD" | grep "Active Profile:" | cut -d ':' -f 2 | xargs)
    if [ "$CURRENT_PROFILE" = "$PROFILE1" ]; then
        pactl set-card-profile "$CARD" "$PROFILE2"
        notify-send "Audio Output" "Tai nghe đã rút. Tự động chuyển về Loa." -i audio-speakers
    else
        notify-send "Audio Output" "Chưa cắm tai nghe!" -i dialog-warning
    fi
else
    # Tai nghe đang cắm
    CURRENT_PROFILE=$(pactl list cards | grep -A 40 "$CARD" | grep "Active Profile:" | cut -d ':' -f 2 | xargs)
    
    if [ "$CURRENT_PROFILE" = "$PROFILE1" ]; then
        pactl set-card-profile "$CARD" "$PROFILE2"
        notify-send "Audio Output" "Đã chuyển sang Loa Laptop" -i audio-speakers
    else
        pactl set-card-profile "$CARD" "$PROFILE1"
        notify-send "Audio Output" "Đã chuyển sang Tai nghe" -i audio-headphones
    fi
fi

