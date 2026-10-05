#!/bin/bash
# Khóa màn hình rồi hibernate (ghi RAM ra /swap.img và tắt nguồn hoàn toàn).
# Chỉ chạy khi kernel đã boot với resume_offset (đã chạy setup-sleep-hibernate.sh và reboot),
# nếu không máy sẽ không khôi phục được phiên làm việc.

notify_fail() {
    notify-send -u critical "Không thể ngủ đông" "$1" -i dialog-warning
}

if ! grep -q 'resume_offset=' /proc/cmdline; then
    notify_fail "Chưa sẵn sàng: hãy chạy setup-sleep-hibernate.sh và khởi động lại máy."
    exit 1
fi

# Ubuntu chặn hibernate qua polkit -> kiểm tra quyền trước khi khóa màn hình
can=$(busctl call org.freedesktop.login1 /org/freedesktop/login1 org.freedesktop.login1.Manager CanHibernate 2>/dev/null | awk '{gsub(/"/, "", $2); print $2}')
if [ "$can" != "yes" ]; then
    notify_fail "Hệ thống từ chối quyền hibernate (CanHibernate=${can:-?}). Chạy: sudo bash ~/setup-sleep-hibernate.sh"
    exit 1
fi

~/.config/sway/scripts/lock.sh

if ! err=$(systemctl hibernate 2>&1); then
    notify_fail "$err"
    exit 1
fi
