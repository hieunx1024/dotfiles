#!/bin/bash

entries=" Khóa màn hình\n Đăng xuất\n󰒲 Ngủ\n󰜉 Khởi động lại\n Tắt máy"
max_len=$(echo -e "$entries" | awk '{if (length($0) > max) max = length($0)} END {print max + 2}')

index=$(echo -e "$entries" | fuzzel -a bottom-right -d -p "" --hide-prompt --minimal-lines -w $max_len --index)

case "$index" in
    0)
        /home/hieunx/.config/sway/scripts/lock.sh
        ;;
    1)
        swaymsg exit
        ;;
    2)
        /home/hieunx/.config/sway/scripts/lock.sh && systemctl suspend
        ;;
    3)
        systemctl reboot
        ;;
    4)
        systemctl poweroff
        ;;
esac
