#!/bin/bash
# Nạp plugin hyprexpo (sudo apt install hyprland-plugin-hyprexpo) rồi áp cấu hình.
# Đặt bằng hyprctl thay vì khối plugin {} trong hyprland.conf: chưa cài plugin thì
# config vẫn sạch lỗi. Gọi bằng `exec =` nên chạy lại sau mỗi lần reload.
# Workspace thuộc về từng màn hình: chỉ liệt kê workspace của màn đang mở overview
# (m~1 = workspace đầu tiên trên màn đó), tránh ô trống giả của màn kia.
SO=/usr/lib/x86_64-linux-gnu/hyprland/plugins/libhyprexpo.so
[ -f "$SO" ] || exit 0

hyprctl plugin list | grep -q hyprexpo || hyprctl plugin load "$SO" >/dev/null

hyprctl --batch "\
keyword plugin:hyprexpo:columns 3;\
keyword plugin:hyprexpo:gap_size 6;\
keyword plugin:hyprexpo:bg_col rgb(141414);\
keyword plugin:hyprexpo:workspace_method first m~1;\
keyword plugin:hyprexpo:skip_empty true;\
keyword hyprexpo-gesture 3, vertical, expo" >/dev/null
