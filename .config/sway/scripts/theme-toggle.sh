#!/bin/bash
# Chuyển theme sáng/tối hệ thống qua chuẩn portal (gsettings color-scheme)
# GTK4/Nautilus/Firefox và các app hỗ trợ portal sẽ tự đổi theo.

current=$(gsettings get org.gnome.desktop.interface color-scheme | tr -d "'")

if [ "$current" = "prefer-dark" ]; then
    NEW_SCHEME="prefer-light"
    GTK_PREFER_DARK=0
else
    NEW_SCHEME="prefer-dark"
    GTK_PREFER_DARK=1
fi

gsettings set org.gnome.desktop.interface color-scheme "$NEW_SCHEME"

CUR_THEME=$(gsettings get org.gnome.desktop.interface gtk-theme | tr -d "'")
if [ "$NEW_SCHEME" = "prefer-light" ]; then
    NEW_THEME="${CUR_THEME%-dark}"
else
    case "$CUR_THEME" in
        *-dark) NEW_THEME="$CUR_THEME" ;;
        *) NEW_THEME="${CUR_THEME}-dark" ;;
    esac
fi
gsettings set org.gnome.desktop.interface gtk-theme "$NEW_THEME"

# GTK3/GTK4 app đọc settings.ini cục bộ (không theo dõi gsettings trực tiếp)
for f in "$HOME/.config/gtk-3.0/settings.ini" "$HOME/.config/gtk-4.0/settings.ini"; do
    [ -f "$f" ] || continue
    sed -i "/^gtk-theme-name=/d;/^gtk-application-prefer-dark-theme=/d" "$f"
    echo "gtk-theme-name=$NEW_THEME" >> "$f"
    echo "gtk-application-prefer-dark-theme=$GTK_PREFER_DARK" >> "$f"
done

notify-send "Theme" "Đã chuyển sang: $NEW_SCHEME ($NEW_THEME)" -i preferences-desktop-theme
