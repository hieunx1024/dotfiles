#!/bin/bash

entries=" Khóa màn hình\n Đăng xuất\n󰒲 Ngủ\n󰜉 Khởi động lại\n Tắt máy"

index=$(echo -e "$entries" | fuzzel -d -p "Hành động: " -w 20 -l 5 --index -a top-right --y-margin=40 --x-margin=10 --no-exit-on-keyboard-focus-loss)

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
