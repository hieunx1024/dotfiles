#!/bin/bash
# Khóa màn hình rồi cho máy ngủ.
# - Kernel đã boot với resume_offset (đã chạy setup-sleep-hibernate.sh + reboot): suspend-then-hibernate
# - Chưa cấu hình / chưa reboot / đã gỡ: suspend thường, tránh hibernate mà không resume được

~/.config/sway/scripts/lock.sh

if grep -q 'resume_offset=' /proc/cmdline && systemctl suspend-then-hibernate; then
    exit 0
fi

systemctl suspend
