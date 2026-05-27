#!/bin/bash

# Pomodoro Timer for Sway + Waybar
# Requirements: notify-send, pkill

STATE_DIR="/tmp/pomodoro"
PID_FILE="$STATE_DIR/pid"
STATUS_FILE="$STATE_DIR/status"
PHASE_FILE="$STATE_DIR/phase"
REMAINING_FILE="$STATE_DIR/remaining"
COUNT_FILE="$STATE_DIR/count"

mkdir -p "$STATE_DIR"

# Times in seconds
WORK_TIME_FILE="$HOME/.config/waybar/scripts/.work_time"
SHORT_BREAK_FILE="$HOME/.config/waybar/scripts/.short_break"
LONG_BREAK_FILE="$HOME/.config/waybar/scripts/.long_break"

get_base_work_time() {
    cat "$WORK_TIME_FILE" 2>/dev/null || echo $((45 * 60))
}
get_base_short_break() {
    cat "$SHORT_BREAK_FILE" 2>/dev/null || echo $((10 * 60))
}
get_base_long_break() {
    cat "$LONG_BREAK_FILE" 2>/dev/null || echo $((15 * 60))
}

WORK_TIME=$(get_base_work_time)
SHORT_BREAK=$(get_base_short_break)
LONG_BREAK=$(get_base_long_break)

send_signal() {
    pkill -RTMIN+2 waybar
}

notify() {
    local msg="$1"
    notify-send -u critical "Pomodoro" "$msg"
}

get_status() {
    if [ ! -f "$STATUS_FILE" ]; then
        echo "stopped"
        return
    fi
    cat "$STATUS_FILE"
}

get_phase() {
    cat "$PHASE_FILE" 2>/dev/null || echo "Work"
}

get_remaining() {
    cat "$REMAINING_FILE" 2>/dev/null || echo "$WORK_TIME"
}

get_count() {
    cat "$COUNT_FILE" 2>/dev/null || echo "0"
}

set_status() { echo "$1" > "$STATUS_FILE"; }
set_phase() { echo "$1" > "$PHASE_FILE"; }
set_remaining() { echo "$1" > "$REMAINING_FILE"; }
set_count() { echo "$1" > "$COUNT_FILE"; }

cleanup() {
    rm -rf "$STATE_DIR"
    send_signal
}

timer_loop() {
    while true; do
        status=$(get_status)
        if [ "$status" = "stopped" ]; then
            exit 0
        fi

        if [ "$status" = "paused" ]; then
            sleep 1
            continue
        fi

        remaining=$(get_remaining)
        phase=$(get_phase)
        count=$(get_count)

        if [ "$remaining" -le 0 ]; then
            local base_work_time=$(get_base_work_time)
            local base_short_break=$(get_base_short_break)
            local base_long_break=$(get_base_long_break)
            if [ "$phase" = "Work" ]; then
                count=$((count + 1))
                set_count "$count"
                notify "Time for a break!"
                if [ $((count % 4)) -eq 0 ]; then
                    set_phase "Long Break"
                    set_remaining "$base_long_break"
                else
                    set_phase "Break"
                    set_remaining "$base_short_break"
                fi
            else
                notify "Back to work!"
                set_phase "Work"
                set_remaining "$base_work_time"
            fi
            send_signal
            sleep 1
            continue
        fi

        remaining=$((remaining - 1))
        set_remaining "$remaining"
        send_signal
        sleep 1
    done
}

start_timer() {
    status=$(get_status)
    if [ "$status" = "running" ]; then
        echo "Already running."
        return
    fi

    if [ "$status" = "paused" ]; then
        set_status "running"
        send_signal
        return
    fi

    # Check for stale PID
    if [ -f "$PID_FILE" ]; then
        pid=$(cat "$PID_FILE")
        if kill -0 "$pid" 2>/dev/null; then
            echo "Script already running with PID $pid"
            return
        fi
    fi

    local base_work_time=$(get_base_work_time)
    set_status "running"
    set_phase "Work"
    set_remaining "$base_work_time"
    set_count "0"

    # Run loop in background
    timer_loop &
    echo $! > "$PID_FILE"
    send_signal
}

pause_timer() {
    status=$(get_status)
    if [ "$status" = "stopped" ]; then
        start_timer
        return
    fi

    if [ "$status" = "running" ]; then
        set_status "paused"
    else
        set_status "running"
    fi
    send_signal
}

stop_timer() {
    if [ -f "$PID_FILE" ]; then
        pid=$(cat "$PID_FILE")
        kill "$pid" 2>/dev/null
    fi
    cleanup
}

clean_duration() {
    local sec="$1"
    local mins=$(( (sec + 30) / 60 ))
    local rounded=$(( ((mins + 2) / 5) * 5 ))
    if [ "$rounded" -lt 5 ]; then rounded=5; fi
    if [ "$rounded" -gt 60 ]; then rounded=60; fi
    echo $((rounded * 60))
}

adjust_time() {
    local delta="$1"
    local status=$(get_status)
    
    if [ "$status" = "stopped" ]; then
        local wt=$(get_base_work_time)
        wt=$((wt + delta))
        wt=$(clean_duration "$wt")
        echo "$wt" > "$WORK_TIME_FILE"
    else
        local remaining=$(get_remaining)
        remaining=$((remaining + delta))
        remaining=$(clean_duration "$remaining")
        set_remaining "$remaining"
    fi
    send_signal
}

prompt_input() {
    local status=$(get_status)
    local icon_work=$(printf '\uf017')
    local icon_break=$(printf '\uf0f4')
    
    # 1. Choose Work Time
    local work_choices="15\n20\n25\n30\n35\n40\n45\n50\n55\n60"
    local selected_work=$(echo -e "$work_choices" | fuzzel -d -p "$icon_work  Chọn thời gian làm việc (phút): " -w 35 -l 10 --no-exit-on-keyboard-focus-loss)
    
    # Check if user cancelled
    if [ -z "$selected_work" ] || ! [[ "$selected_work" =~ ^[0-9]+$ ]]; then
        return
    fi
    
    # 2. Choose Break Time
    local break_choices="5\n10\n15\n20\n25\n30"
    local selected_break=$(echo -e "$break_choices" | fuzzel -d -p "$icon_break  Chọn thời gian nghỉ (phút): " -w 35 -l 6 --no-exit-on-keyboard-focus-loss)
    
    # Parse values
    local work_seconds=$((selected_work * 60))
    local break_seconds=$((selected_break * 60))
    
    # Set values
    echo "$work_seconds" > "$WORK_TIME_FILE"
    echo "$break_seconds" > "$SHORT_BREAK_FILE"
    
    # If the timer is NOT stopped, update the currently remaining time as well!
    if [ "$status" != "stopped" ]; then
        set_remaining "$work_seconds"
    fi
    
    # Notify user via SwayNC/notify-send
    notify-send -u low "Pomodoro" "Đã đặt: Làm việc ${selected_work}p | Nghỉ ${selected_break}p"
    
    send_signal
}

status_output() {
    status=$(get_status)
    if [ "$status" = "stopped" ]; then
        local work_time=$(get_base_work_time)
        local minutes=$((work_time / 60))
        printf "<span alpha='35%%'>\U000f13ac (%02dm)</span>\n" "$minutes"
        return
    fi

    phase=$(get_phase)
    remaining=$(get_remaining)
    
    minutes=$((remaining / 60))
    seconds=$((remaining % 60))
    
    icon=$(printf '\uf017')
    if [ "$phase" != "Work" ]; then
        icon=$(printf '\uf0f4')
    fi
    
    paused_indicator=""
    if [ "$status" = "paused" ]; then
        paused_indicator=" (Paused)"
    fi

    printf "%02d:%02d %s%s\n" "$minutes" "$seconds" "$phase" "$paused_indicator"
}

case "$1" in
    start)
        start_timer
        ;;
    pause)
        pause_timer
        ;;
    stop)
        stop_timer
        ;;
    adjust)
        adjust_time "$2"
        ;;
    input)
        prompt_input
        ;;
    status|*)
        status_output
        ;;
esac
