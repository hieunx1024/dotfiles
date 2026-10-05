#!/bin/bash
# Bật/tắt chế độ minimal của waybar (giống swaybar mặc định).
# Tắt minimal -> quay về layout đầy đủ với theme hiện tại (~/.config/sway/current_theme).

WAYBAR_DIR="$HOME/.config/waybar"
THEME_DIR="$WAYBAR_DIR/themes"

if [ "$(basename "$(dirname "$(readlink -f "$WAYBAR_DIR/config.jsonc")")")" = "minimal" ]; then
    THEME=$(cat "$HOME/.config/sway/current_theme" 2>/dev/null)
    [ -d "$THEME_DIR/$THEME" ] && [ "$THEME" != "minimal" ] || THEME="monochrome"

    STYLE="style.css"
    if [ "$(gsettings get org.gnome.desktop.interface color-scheme 2>/dev/null)" = "'prefer-light'" ] \
        && [ -f "$THEME_DIR/$THEME/style-light.css" ]; then
        STYLE="style-light.css"
    fi
    MSG="Waybar: chế độ đầy đủ ($THEME)"
else
    THEME="minimal"
    STYLE="style.css"
    MSG="Waybar: chế độ minimal"
fi

if [ -e "$THEME_DIR/$THEME/config.jsonc" ]; then
    ln -sfn "themes/$THEME/config.jsonc" "$WAYBAR_DIR/config.jsonc"
else
    ln -sfn "shared/config.jsonc" "$WAYBAR_DIR/config.jsonc"
fi
ln -sfn "themes/$THEME/$STYLE" "$WAYBAR_DIR/style.css"

pkill waybar 2>/dev/null
for _ in {1..20}; do
    pgrep -x waybar >/dev/null || break
    sleep 0.1
done
sleep 0.2
nohup ~/.config/sway/scripts/statusbar.sh >/dev/null 2>&1 &
disown

notify-send "Waybar" "$MSG" -i preferences-desktop-theme
