#!/bin/bash
# Thiết lập quyền điều chỉnh xung nhịp và Turbo Boost cho CPU (chạy một lần với sudo)

if [ "$EUID" -ne 0 ]; then
    echo "Lỗi: Script này cần quyền root để thiết lập quyền truy cập phần cứng."
    echo "Vui lòng chạy: sudo $0"
    exit 1
fi

cat << 'EOF' > /etc/tmpfiles.d/cpu-power.conf
# Cho phép nhóm sudo điều chỉnh xung nhịp, EPP và Turbo Boost của CPU trực tiếp không cần mật khẩu
z /sys/devices/system/cpu/cpufreq/boost 0664 root sudo -
z /sys/devices/system/cpu/cpu*/cpufreq/scaling_max_freq 0664 root sudo -
z /sys/devices/system/cpu/cpu*/cpufreq/scaling_min_freq 0664 root sudo -
z /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference 0664 root sudo -
EOF

# Áp dụng quyền ngay lập tức
systemd-tmpfiles --create /etc/tmpfiles.d/cpu-power.conf

echo "✓ Đã cấp quyền điều chỉnh xung nhịp & Turbo Boost cho nhóm sudo thành công!"
echo "✓ Từ bây giờ, chế độ Power Saver trên Waybar sẽ tự động khóa trần xung nhịp và tắt Turbo Boost."
