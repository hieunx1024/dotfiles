#!/usr/bin/env bash

set -u

STATE_DIR="${XDG_RUNTIME_DIR:-/tmp}/hypr-scratch-state"
client="$(hyprctl activewindow -j 2>/dev/null)" || exit 0
address="$(jq -r '.address // ""' <<<"$client")"
current_workspace="$(jq -r '.workspace.name // ""' <<<"$client")"

[[ -n "$address" && "$current_workspace" == special:* ]] || exit 0

state_file="$STATE_DIR/${address#0x}.json"

if [[ ! -s "$state_file" ]]; then
    # App scratchpad cố định hoặc trạng thái thuộc phiên cũ: đưa về workspace hiện tại dạng tiled.
    target_workspace="$(hyprctl activeworkspace -j 2>/dev/null | jq -r '.name')"
    hyprctl dispatch movetoworkspace "$target_workspace,address:$address" >/dev/null
    hyprctl dispatch settiled "address:$address" >/dev/null
    exit 0
fi

target_workspace="$(jq -r '.workspace' "$state_file")"
was_floating="$(jq -r '.floating' "$state_file")"
old_x="$(jq -r '.at[0]' "$state_file")"
old_y="$(jq -r '.at[1]' "$state_file")"
old_width="$(jq -r '.size[0]' "$state_file")"
old_height="$(jq -r '.size[1]' "$state_file")"

hyprctl dispatch movetoworkspace "$target_workspace,address:$address" >/dev/null
sleep 0.05

if [[ "$was_floating" == "true" ]]; then
    hyprctl dispatch setfloating "address:$address" >/dev/null
    hyprctl dispatch resizewindowpixel \
        "exact $old_width $old_height,address:$address" >/dev/null
    hyprctl dispatch movewindowpixel \
        "exact $old_x $old_y,address:$address" >/dev/null
else
    hyprctl dispatch settiled "address:$address" >/dev/null
fi

hyprctl dispatch focuswindow "address:$address" >/dev/null
unlink "$state_file"
