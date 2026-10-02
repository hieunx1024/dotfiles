#!/bin/bash
# Kill -9 tiến trình của cửa sổ đang focus (dùng khi app treo, Super+Q không đóng được).
PID=$(hyprctl activewindow -j | jq -r '.pid // empty')
[ -n "$PID" ] && [ "$PID" -gt 1 ] && kill -9 "$PID"
