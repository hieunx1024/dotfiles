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
WORK_TIME=$((45 * 60))
SHORT_BREAK=$((10 * 60))
LONG_BREAK=$((15 * 60))

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
            if [ "$phase" = "Work" ]; then
                count=$((count + 1))
                set_count "$count"
                notify "Time for a break!"
                if [ $((count % 4)) -eq 0 ]; then
                    set_phase "Long Break"
                    set_remaining "$LONG_BREAK"
                else
                    set_phase "Break"
                    set_remaining "$SHORT_BREAK"
                fi
            else
                notify "Back to work!"
                set_phase "Work"
                set_remaining "$WORK_TIME"
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

    set_status "running"
    set_phase "Work"
    set_remaining "$WORK_TIME"
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

status_output() {
    status=$(get_status)
    if [ "$status" = "stopped" ]; then
        printf "<span alpha='35%%'>\U000f13ac</span>\n"
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
    status|*)
        status_output
        ;;
esac
