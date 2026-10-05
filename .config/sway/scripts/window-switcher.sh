#!/bin/bash
# Danh sách cửa sổ nhóm theo workspace, kèm icon app (Super+Tab)

rows=$(swaymsg -t get_tree | jq -r '
def windows_in(ws):
  ws as $w
  | [($w.nodes // [])[], ($w.floating_nodes // [])[]]
  | .. | objects
  | select((.type=="con" or .type=="floating_con") and .name != null and .name != "" and (.app_id != null or .window_properties.class? != null))
  | [
      (if $w.name == "__i3_scratch" then "scratch" else ($w.num // $w.name // "?") | tostring end),
      .id,
      (.app_id // .window_properties.class // "unknown"),
      .name
    ];

[.. | objects | select(.type=="workspace")]
| sort_by(.num // 999)
| map(windows_in(.))
| .[]
| @tsv
')

if [ -z "$rows" ]; then
    exit 0
fi

# Nhiều app_id không trùng tên icon thật (vd: com.anthropic.Claude -> claude-desktop,
# org.fcitx.fcitx5-config-qt -> fcitx, jetbrains-idea -> đường dẫn tuyệt đối,
# viber -> /usr/share/pixmaps/viber.png).
# Tra icon thật từ file .desktop tương ứng thay vì đoán theo app_id.
resolve_icon() {
    local appid="$1"
    local desktop_file icon
    desktop_file=$(find /usr/share/applications ~/.local/share/applications -maxdepth 1 -iname "${appid}.desktop" 2>/dev/null | head -1)
    if [ -z "$desktop_file" ]; then
        desktop_file=$(grep -rl "^StartupWMClass=${appid}$" /usr/share/applications ~/.local/share/applications 2>/dev/null | head -1)
    fi
    if [ -n "$desktop_file" ]; then
        icon=$(grep -m1 "^Icon=" "$desktop_file" | cut -d= -f2- | tr -d '\r"' | tr -d "'")
        if [ -n "$icon" ]; then
            if [ -f "$icon" ]; then
                echo "$icon"
                return
            fi
            for ext in "" ".png" ".svg"; do
                if [ -f "/usr/share/pixmaps/${icon}${ext}" ]; then
                    echo "/usr/share/pixmaps/${icon}${ext}"
                    return
                fi
            done
            echo "$icon"
            return
        fi
    fi
    for ext in ".png" ".svg"; do
        if [ -f "/usr/share/pixmaps/${appid}${ext}" ]; then
            echo "/usr/share/pixmaps/${appid}${ext}"
            return
        fi
    done
    echo "$appid"
}

max_len=$(echo "$rows" | awk -F'\t' '{tag="[WS" $1 "]"; if($1=="scratch") tag="[Scratch]"; len=length(tag " " $3 " — " $4); if(len > 100) len=100; if (len > max) max = len} END {if(max<30) max=30; print max + 2}')
num_lines=$(echo "$rows" | wc -l)

id=$(echo "$rows" | while IFS=$'\t' read -r ws wid appid title; do
    icon=$(resolve_icon "$appid")
    ws_tag="[WS${ws}]"
    [ "$ws" = "scratch" ] && ws_tag="[Scratch]"
    printf '%s\t%s %s — %s\x00icon\x1f%s\n' "$wid" "$ws_tag" "$appid" "$title" "$icon"
done | fuzzel -d -p "󰖯 Switch ❯ " --with-nth=2 --accept-nth=1 -l "$num_lines" -w "$max_len")

if [ -n "$id" ]; then
    sleep 0.1
    swaymsg "[con_id=$id] focus"
fi
