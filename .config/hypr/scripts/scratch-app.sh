#!/usr/bin/env bash

set -u

class_regex="${1:?usage: scratch-app.sh CLASS_REGEX WORKSPACE [--show|--toggle]}"
workspace="${2:?usage: scratch-app.sh CLASS_REGEX WORKSPACE [--show|--toggle]}"
mode="${3:---toggle}"

client_exists() {
    hyprctl clients -j 2>/dev/null \
        | jq -e --arg regex "$class_regex" 'any(.[]; .class | test($regex))' >/dev/null
}

workspace_visible() {
    hyprctl monitors -j 2>/dev/null \
        | jq -e --arg workspace "special:$workspace" \
            'any(.[]; .specialWorkspace.name == $workspace)' >/dev/null
}

active_matches() {
    hyprctl activewindow -j 2>/dev/null \
        | jq -e --arg regex "$class_regex" '.class | test($regex)' >/dev/null
}

client_exists || exit 0

if [[ "$mode" == "--toggle" ]] && workspace_visible && active_matches; then
    hyprctl dispatch togglespecialworkspace "$workspace" >/dev/null
    exit 0
fi

if ! workspace_visible; then
    hyprctl dispatch togglespecialworkspace "$workspace" >/dev/null
    sleep 0.05
fi

hyprctl dispatch focuswindow "class:$class_regex" >/dev/null
