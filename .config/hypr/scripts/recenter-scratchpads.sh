#!/usr/bin/env bash

set -u

monitors="$(hyprctl monitors -j 2>/dev/null)" || exit 0
clients="$(hyprctl clients -j 2>/dev/null)" || exit 0

# Giữ cửa sổ trên monitor cũ nếu monitor đó còn bật. Nếu monitor đã bị tắt,
# dùng monitor đang focus rồi tính lại tọa độ giữa theo kích thước logic.
jq -rn \
    --argjson monitors "$monitors" \
    --argjson clients "$clients" '
    ($monitors | map(select(.focused))[0] // $monitors[0]) as $fallback
    | $clients[]
    | select(.workspace.name | test("^special:(discord|spotify|viber|scratch(-.*)?)$"))
    | . as $client
    | (($monitors | map(select(.id == $client.monitor))[0]) // $fallback) as $monitor
    | ($monitor.width / $monitor.scale) as $monitor_width
    | ($monitor.height / $monitor.scale) as $monitor_height
    | [
        $client.address,
        ($monitor.x + (if $client.size[0] >= $monitor_width then 0
                       else (($monitor_width - $client.size[0]) / 2 | floor) end)),
        ($monitor.y + (if $client.size[1] >= $monitor_height then 0
                       else (($monitor_height - $client.size[1]) / 2 | floor) end))
      ]
    | @tsv
' | while IFS=$'\t' read -r address x y; do
    hyprctl dispatch movewindowpixel "exact $x $y,address:$address" >/dev/null
done
