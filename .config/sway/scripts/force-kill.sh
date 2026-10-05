#!/bin/bash
# =============================================================================
# FORCE KILL FOCUSED WINDOW IN SWAY (SIGKILL)
# =============================================================================

# Get focused window details from Sway
FOCUSED_JSON=$(swaymsg -t get_tree | jq '.. | select(.type?) | select(.focused==true)')

PID=$(echo "$FOCUSED_JSON" | jq -r '.pid // empty')
NAME=$(echo "$FOCUSED_JSON" | jq -r '.name // .window_properties.title // "ứng dụng"')

if [ -n "$PID" ] && [ "$PID" -gt 0 ]; then
    PNAME=$(ps -p "$PID" -o comm= 2>/dev/null)

    # Recursively kill all child processes then parent
    kill_tree() {
        local parent=$1
        for child in $(pgrep -P "$parent" 2>/dev/null); do
            kill_tree "$child"
        done
        kill -9 "$parent" 2>/dev/null
    }

    kill_tree "$PID"

    # Specific cleanup for applications with separate helper daemons
    if [ "$PNAME" = "DesktopEditors" ]; then
        pkill -9 -f "editors_helper" 2>/dev/null
    fi

    notify-send -t 2000 -i application-exit "Force Kill" "Đã ép dừng: $NAME"
else
    # Fallback to standard sway kill
    swaymsg kill
fi
