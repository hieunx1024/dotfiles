#!/bin/bash

# Script to update SDDM wallpaper to match current desktop wallpaper
# Theme: gruvbox-minimal

# Get current wallpaper from waypaper config
WALLPAPER=$(grep '^wallpaper =' ~/.config/waypaper/config.ini | cut -d ' ' -f 3 | sed "s|~|$HOME|")

if [ -f "$WALLPAPER" ]; then
    echo "Current wallpaper: $WALLPAPER"
    
    # Target file
    TARGET="/var/tmp/sddm_wallpaper.jpg"
    
    echo "Updating SDDM wallpaper..."
    cp "$WALLPAPER" "$TARGET"
    
    if [ $? -eq 0 ]; then
        notify-send "SDDM Wallpaper" "Đã cập nhật ảnh nền SDDM thành công!" -i image-x-generic
        echo "Success!"
    else
        notify-send "SDDM Wallpaper" "Lỗi khi cập nhật ảnh nền SDDM!" -i dialog-error
        echo "Failed to copy files."
    fi
else
    echo "Error: Wallpaper file not found: $WALLPAPER"
    notify-send "SDDM Wallpaper" "Không tìm thấy file ảnh nền!" -i dialog-error
fi
