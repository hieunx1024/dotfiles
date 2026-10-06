#!/usr/bin/env python3
"""
cycle-workspace.py - Chuyển workspace thông minh chỉ qua các workspace đang có cửa sổ.
Bỏ qua hoàn toàn các workspace rỗng ma (ghost empty workspaces).

Cách dùng:
    cycle-workspace.py next [loop|noloop]
    cycle-workspace.py prev [loop|noloop]
"""

import json
import subprocess
import sys

def main():
    direction = sys.argv[1] if len(sys.argv) > 1 else "next"
    mode = sys.argv[2] if len(sys.argv) > 2 else "loop"
    do_loop = (mode == "loop" or mode == "true")

    try:
        ws_output = subprocess.check_output(["hyprctl", "workspaces", "-j"], stderr=subprocess.DEVNULL)
        active_output = subprocess.check_output(["hyprctl", "activeworkspace", "-j"], stderr=subprocess.DEVNULL)
        workspaces = json.loads(ws_output)
        active_ws = json.loads(active_output)
    except Exception:
        sys.exit(0)

    active_id = active_ws.get("id")
    if active_id is None:
        sys.exit(0)

    # Lọc danh sách workspace hợp lệ: có ít nhất 1 cửa sổ (>0) và ID > 0 (bỏ special workspace),
    # đồng thời giữ lại active_id hiện tại để có điểm neo.
    valid_ids = sorted(list(set(
        [w["id"] for w in workspaces if w.get("windows", 0) > 0 and w.get("id", 0) > 0]
        + [active_id]
    )))

    if len(valid_ids) <= 1:
        sys.exit(0)

    try:
        curr_idx = valid_ids.index(active_id)
    except ValueError:
        sys.exit(0)

    if direction == "next":
        if curr_idx + 1 < len(valid_ids):
            target_id = valid_ids[curr_idx + 1]
        elif do_loop:
            target_id = valid_ids[0]
        else:
            target_id = active_id
    else:  # prev
        if curr_idx - 1 >= 0:
            target_id = valid_ids[curr_idx - 1]
        elif do_loop:
            target_id = valid_ids[-1]
        else:
            target_id = active_id

    if target_id != active_id:
        subprocess.run(
            ["hyprctl", "dispatch", "workspace", str(target_id)],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL
        )

if __name__ == "__main__":
    main()
