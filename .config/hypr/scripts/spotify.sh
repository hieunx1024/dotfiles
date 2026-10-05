#!/usr/bin/env bash

set -u

mode="${1:---show}"
if [[ "$mode" == "--show" || "$mode" == "--toggle" ]]; then
    shift
else
    mode="--show"
fi

if [ "${XDG_CURRENT_DESKTOP:-}" = "sway" ] || [ -n "${SWAYSOCK:-}" ]; then
    if swaymsg -t get_tree 2>/dev/null | jq -e '.. | select(.app_id? == "spotify" or .window_properties?.class? == "Spotify")' >/dev/null; then
        swaymsg '[class="(?i)spotify"] scratchpad show'
        exit 0
    fi
    /usr/bin/spotify --enable-features=UseOzonePlatform --ozone-platform=wayland "$@" >/dev/null 2>&1 &
    exit 0
fi

spotify_client_exists() {
    hyprctl clients -j 2>/dev/null \
        | jq -e 'any(.[]; (.class | ascii_downcase) == "spotify")' >/dev/null
}

if spotify_client_exists; then
    "$HOME/.config/hypr/scripts/scratch-app.sh" '(?i)spotify' spotify "$mode"
    exit 0
fi

# Spotify mặc định chạy qua X11. Dùng Ozone/Wayland để không phụ thuộc XWayland.
/usr/bin/spotify \
    --enable-features=UseOzonePlatform \
    --ozone-platform=wayland \
    "$@" >/dev/null 2>&1 &

# Window rule đưa Spotify vào special workspace riêng; mở nó sau khi cửa sổ sẵn sàng.
for _ in {1..100}; do
    if spotify_client_exists; then
        "$HOME/.config/hypr/scripts/scratch-app.sh" '(?i)spotify' spotify --show
        exit 0
    fi
    sleep 0.1
done

exit 1
