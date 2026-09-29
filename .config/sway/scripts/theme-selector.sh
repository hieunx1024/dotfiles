#!/bin/bash
# =============================================================================
# THEME SELECTOR & SWITCHER FOR SWAY DESKTOP
# Supports: Sway, Waybar, Kitty, Fuzzel, SwayNC, Wlogout
# Usage:
#   theme-selector.sh              (Opens Fuzzel menu)
#   theme-selector.sh <theme-name> (Directly applies theme)
# =============================================================================

DOTFILES="$HOME/Desktop/dotfiles/.config"

# Danh sách theme và mô tả
declare -A THEMES
THEMES["monochrome"]="󰔎  Monochrome        • Pure Black & White Minimalist"
THEMES["gruvbox"]="󰟡  Gruvbox Dark      • Retro Warm Earth"
THEMES["tokyonight"]="󰖔  Tokyo Night       • Deep Midnight Blue & Cyan"
THEMES["dracula"]="󰄛  Dracula Dark      • Purple & Pink Neon"
THEMES["white"]="󰄯  Pure White        • High-Contrast Light"
THEMES["sepia"]="󰷉  Sepia Paper       • Vintage Warm Paper"

apply_theme() {
    local target="$1"

    # Kiểm tra tính hợp lệ
    case "$target" in
        dracula|tokyonight|gruvbox|monochrome|white|sepia) ;;
        *)
            notify-send "Theme Switcher" "Theme không hợp lệ: $target" -u critical
            exit 1
            ;;
    esac

    # 1. Cập nhật Sway
    (cd "$HOME/.config/sway" && ln -sfn "themes/${target}.conf" "theme.conf")

    # 2. Cập nhật Waybar
    if [ -d "$HOME/.config/waybar/themes/${target}" ]; then
        (cd "$HOME/.config/waybar" && ln -sfn "themes/${target}/config.jsonc" "config.jsonc" && ln -sfn "themes/${target}/style.css" "style.css")
    fi

    # 3. Cập nhật Kitty
    if [ -f "$HOME/.config/kitty/themes/${target}.conf" ]; then
        (cd "$HOME/.config/kitty" && ln -sfn "themes/${target}.conf" "current-theme.conf")
        kill -SIGUSR1 $(pidof kitty) 2>/dev/null || true
    fi

    # 4. Cập nhật Fuzzel
    if [ -f "$HOME/.config/fuzzel/themes/${target}.ini" ]; then
        (cd "$HOME/.config/fuzzel" && ln -sfn "themes/${target}.ini" "theme.ini")
    fi

    # 5. Cập nhật SwayNC
    if [ -f "$HOME/.config/swaync/themes/${target}.css" ]; then
        (cd "$HOME/.config/swaync" && ln -sfn "themes/${target}.css" "colors.css")
        swaync-client -rs >/dev/null 2>&1 || true
    fi

    # 6. Cập nhật Wlogout
    if [ -f "$HOME/.config/wlogout/themes/${target}.css" ]; then
        (cd "$HOME/.config/wlogout" && ln -sfn "themes/${target}.css" "colors.css")
    fi

    # 7. Reload Sway (tự động cập nhật màu viền Sway & restart Waybar)
    swaymsg reload >/dev/null 2>&1

    # Lưu trạng thái theme hiện tại
    echo "$target" > "$HOME/.config/sway/current_theme"

    # Hiển thị thông báo
    local title="Dracula Dark"
    [ "$target" = "tokyonight" ] && title="Tokyo Night"
    [ "$target" = "gruvbox" ] && title="Gruvbox Dark"
    [ "$target" = "monochrome" ] && title="Monochrome (Đen Trắng)"
    [ "$target" = "white" ] && title="Pure White (Trắng Đen)"
    [ "$target" = "sepia" ] && title="Sepia Paper (Giấy Cổ)"
    notify-send "Giao diện hệ thống" "Đã chuyển sang theme: $title" -i preferences-desktop-theme
}

# Nếu có tham số truyền vào -> áp dụng trực tiếp
if [ -n "$1" ]; then
    apply_theme "$1"
    exit 0
fi

# Nếu không có tham số -> Mở menu Fuzzel
MENU_OPTIONS="${THEMES["monochrome"]}\n${THEMES["gruvbox"]}\n${THEMES["tokyonight"]}\n${THEMES["dracula"]}\n${THEMES["white"]}\n${THEMES["sepia"]}"

SELECTED=$(echo -e "$MENU_OPTIONS" | fuzzel --dmenu --prompt="󰔎 Theme ❯ " --width=52 --lines=6)

[ -z "$SELECTED" ] && exit 0

case "$SELECTED" in
    *"Dracula"*)
        apply_theme "dracula"
        ;;
    *"Tokyo Night"*)
        apply_theme "tokyonight"
        ;;
    *"Gruvbox Dark"*)
        apply_theme "gruvbox"
        ;;
    *"Monochrome"*)
        apply_theme "monochrome"
        ;;
    *"Pure White"*)
        apply_theme "white"
        ;;
    *"Sepia"*)
        apply_theme "sepia"
        ;;
esac
