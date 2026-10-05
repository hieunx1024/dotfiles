#!/usr/bin/env bash

set -u

mapfile -t scratch_workspaces < <(
    hyprctl clients -j 2>/dev/null \
        | jq -r '[
            .[]
            | .workspace.name
            | select(test("^special:(discord|spotify|viber|scratch(-.*)?)$"))
        ] | unique[]'
)

workspace_count="${#scratch_workspaces[@]}"
((workspace_count > 0)) || exit 0

visible_workspace="$({
    hyprctl monitors -j 2>/dev/null \
        | jq -r '[.[] | select(.focused)][0].specialWorkspace.name // ""'
} || true)"

next_index=0

for index in "${!scratch_workspaces[@]}"; do
    if [[ "${scratch_workspaces[$index]}" == "$visible_workspace" ]]; then
        # Sau cửa sổ cuối cùng là một trạng thái ẩn, giống vòng scratchpad của Sway.
        if ((index == workspace_count - 1)); then
            hyprctl dispatch togglespecialworkspace "${visible_workspace#special:}" >/dev/null
            exit 0
        fi
        next_index=$((index + 1))
        break
    fi
done

hyprctl dispatch togglespecialworkspace "${scratch_workspaces[$next_index]#special:}" >/dev/null
