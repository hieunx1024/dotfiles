#!/bin/bash
# Chọn theme đồng bộ cho toàn bộ phiên Hyprland:
# compositor, overview, lockscreen, Waybar, Kitty, Fuzzel, SwayNC, Wlogout và GTK.

set -u

HYPR="$HOME/.config/hypr"

declare -A THEMES=(
    [monochrome]="󰔎  Monochrome        • Pure Black & White"
    [gruvbox]="󰟡  Gruvbox Dark      • Retro Warm Earth"
    [tokyonight]="󰖔  Tokyo Night       • Midnight Blue & Cyan"
    [graphite]="󰝤  Graphite          • Neutral Gray & Ivory"
    [dracula]="󰄛  Dracula Dark      • Purple & Pink Neon"
    [white]="󰄯  Pure White        • High-Contrast Light"
    [sepia]="󰷉  Sepia Paper       • Vintage Warm Paper"
)

icon_theme_of() {
    case "$1" in sepia|white) echo Papirus-Light ;; *) echo Papirus-Dark ;; esac
}

# Chọn theme cho bản kitty/fuzzel/swaync/wlogout riêng của Hyprland (apps/, xem apps/README.md).
# Mọi thứ nằm trong $HYPR/apps - không đọc/ghi ~/.config/<app> của sway.
write_app_themes() {
    local target="$1" icon_theme="$2" apps="$HYPR/apps"
    ln -sfn "themes/$target.conf" "$apps/kitty/current-theme.conf"
    printf '[main]\nicon-theme=%s\ninclude=%s/fuzzel/themes/%s.ini\n' "$icon_theme" "$apps" "$target" > "$apps/fuzzel/theme.ini"
    ln -sfn "themes/$target.css" "$apps/swaync/colors.css"
    ln -sfn "themes/$target.css" "$apps/wlogout/colors.css"
}

apply_theme() {
    local target="$1" scheme title gtk_theme icon_theme
    case "$target" in
        monochrome|gruvbox|tokyonight|graphite|dracula|white|sepia) ;;
        *) notify-send "Theme Switcher" "Theme không hợp lệ: $target" -u critical; return 1 ;;
    esac

    case "$target" in
        monochrome) gtk_theme=Yaru-dark;             icon_theme=Papirus-Dark;  scheme=prefer-dark ;;
        gruvbox)    gtk_theme=Yaru-wartybrown-dark;  icon_theme=Papirus-Dark;  scheme=prefer-dark ;;
        tokyonight) gtk_theme=Yaru-blue-dark;        icon_theme=Papirus-Dark;  scheme=prefer-dark ;;
        graphite)   gtk_theme=Adwaita-dark;          icon_theme=Papirus-Dark;  scheme=prefer-dark ;;
        dracula)    gtk_theme=Yaru-purple-dark;      icon_theme=Papirus-Dark;  scheme=prefer-dark ;;
        sepia)      gtk_theme=Yaru-wartybrown;       icon_theme=Papirus-Light; scheme=prefer-light ;;
        white)      gtk_theme=Yaru;                  icon_theme=Papirus-Light; scheme=prefer-light ;;
    esac

    cp "$HYPR/themes/$target.conf" "$HYPR/theme.conf"
    cp "$HYPR/waybar/themes/$target.css" "$HYPR/waybar/colors.css"

    # kitty/fuzzel/swaync/wlogout: chỉ ghi theme vào $HYPR/apps (bản riêng của Hyprland), KHÔNG đụng
    # ~/.config/<app> của sway (03/10: bản cũ ghi đè theme kitty/fuzzel/swaync/gtk của sway).
    write_app_themes "$target" "$icon_theme"
    pkill -SIGUSR1 -x kitty 2>/dev/null || true
    timeout 2s swaync-client -rs >/dev/null 2>&1 || true

    # GTK3/GTK4, Nautilus và app theo portal cùng chuyển sáng/tối và accent gần palette.
    # Chỉ ghi gsettings: session-theme.sh lưu riêng cho phiên Hyprland. Không ghi gtk-3.0/4.0
    # settings.ini hay ~/.gtkrc-2.0 (file của sway).
    gsettings set org.gnome.desktop.interface color-scheme "$scheme" 2>/dev/null || true
    gsettings set org.gnome.desktop.interface gtk-theme "$gtk_theme" 2>/dev/null || true
    gsettings set org.gnome.desktop.interface icon-theme "$icon_theme" 2>/dev/null || true

    printf '%s\n' "$target" > "$HYPR/current_theme"
    timeout 2s hyprctl reload >/dev/null 2>&1 || true
    pkill -SIGUSR2 waybar 2>/dev/null || true

    case "$target" in
        monochrome) title="Monochrome" ;; gruvbox) title="Gruvbox Dark" ;;
        tokyonight) title="Tokyo Night" ;; graphite) title="Graphite" ;; dracula) title="Dracula Dark" ;;
        white) title="Pure White" ;; sepia) title="Sepia Paper" ;;
    esac
    timeout 2s notify-send "Giao diện Hyprland" "Đã chuyển sang theme: $title" -i preferences-desktop-theme || true
}

if [ "${1:-}" = --apps ]; then
    cur=$(cat "$HYPR/current_theme" 2>/dev/null || printf monochrome)
    write_app_themes "$cur" "$(icon_theme_of "$cur")"
    exit 0
fi

if [ -n "${1:-}" ]; then
    apply_theme "$1"
    exit $?
fi

options="${THEMES[monochrome]}\n${THEMES[gruvbox]}\n${THEMES[tokyonight]}\n${THEMES[graphite]}\n${THEMES[dracula]}\n${THEMES[white]}\n${THEMES[sepia]}"
selected=$(printf '%b' "$options" | fuzzel --dmenu --prompt="󰔎 Theme ❯ " --width=52 --lines=7)
[ -n "$selected" ] || exit 0

case "$selected" in
    *Monochrome*) apply_theme monochrome ;; *Gruvbox*) apply_theme gruvbox ;;
    *Tokyo*) apply_theme tokyonight ;; *Graphite*) apply_theme graphite ;; *Dracula*) apply_theme dracula ;;
    *White*) apply_theme white ;; *Sepia*) apply_theme sepia ;;
esac
