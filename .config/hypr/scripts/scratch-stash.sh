#!/usr/bin/env bash

set -u

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
STATE_DIR="${XDG_RUNTIME_DIR:-/tmp}/hypr-scratch-state"

client="$(hyprctl activewindow -j 2>/dev/null)" || exit 0
address="$(jq -r '.address // ""' <<<"$client")"
[[ -n "$address" ]] || exit 0

original_workspace="$(jq -r '.workspace.name // ""' <<<"$client")"
[[ "$original_workspace" != special:* ]] || exit 0

mkdir -p "$STATE_DIR"
state_file="$STATE_DIR/${address#0x}.json"

# Lưu đủ trạng thái hình học trước khi chuyển sang scratchpad.
jq '{
    address,
    workspace: .workspace.name,
    floating,
    at,
    size,
    fullscreen
}' <<<"$client" >"$state_file.tmp"
mv -f "$state_file.tmp" "$state_file"

# Mỗi cửa sổ thường có workspace ẩn riêng để lúc gọi lại không hiện cả chồng cửa sổ.
workspace="scratch-${address#0x}"
hyprctl dispatch setfloating "address:$address" >/dev/null
hyprctl dispatch resizewindowpixel "exact 1200 800,address:$address" >/dev/null
hyprctl dispatch movetoworkspacesilent "special:$workspace,address:$address" >/dev/null
sleep 0.05
"$SCRIPT_DIR/recenter-scratchpads.sh"
