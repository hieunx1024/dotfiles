#!/bin/bash
# Build + cài plugin Hyprspace (overview mọi workspace trên tất cả màn hình) cho Hyprland
# bản apt, KHÔNG cần sudo: header -dev được giải nén vào thư mục tạm.
#
# Commit bcd9692 = bản cuối của upstream cho Hyprland 0.53, kèm hyprspace-0.53.patch:
#   - backport dac99cb: reserved area dồn tích mỗi lần mở/đóng -> ASSERT abort Hyprland
#   - backport 700f613: gestures:workspace_swipe_fingers không còn ở 0.53 -> segfault khi vuốt
#   - từ chối nạp khi lệch hash với Hyprland đang chạy (sau apt upgrade) thay vì crash
# Khi nâng Hyprland lên 0.54+: bỏ patch, chọn COMMIT theo hyprpm.toml của repo.
set -euo pipefail
COMMIT=${COMMIT:-bcd9692}
PATCH=$(dirname "$(readlink -f "$0")")/hyprspace-0.53.patch
OUT=$HOME/.local/lib/hyprland/Hyprspace.so
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

git clone -q https://github.com/KZDKM/Hyprspace.git "$TMP/src"
git -C "$TMP/src" checkout -q "$COMMIT"
[ "$COMMIT" = bcd9692 ] && git -C "$TMP/src" apply "$PATCH"

DEVS="hyprland-dev libpixman-1-dev libpango1.0-dev libudev-dev libinput-dev libcairo2-dev
libdrm-dev libwayland-dev libxkbcommon-dev libaquamarine-dev libhyprutils-dev libhyprlang-dev
libhyprgraphics-dev libhyprcursor-dev libharfbuzz-dev libfreetype-dev libfontconfig-dev
libgles-dev libegl-dev libgl-dev libglx-dev x11proto-dev libx11-dev libxcb1-dev libxrender-dev
libxext-dev libpng-dev libfribidi-dev libthai-dev libdatrie-dev libxft-dev libxau-dev
libxdmcp-dev libxcb-render0-dev libxcb-shm0-dev libxcb-composite0-dev libxcb-errors-dev
libxcb-icccm4-dev libxcb-res0-dev libxcb-xfixes0-dev libgraphite2-dev libbrotli-dev
libbz2-dev libevdev-dev libmtdev-dev libwacom-dev libgudev-1.0-dev"
SYSROOT=$TMP/sysroot
mkdir -p "$TMP/debs" && (cd "$TMP/debs" && apt-get download -q $DEVS >/dev/null)
for d in "$TMP"/debs/*.deb; do dpkg-deb -x "$d" "$SYSROOT"; done
# .pc trỏ prefix=/usr -> trỏ về sysroot
find "$SYSROOT" -name '*.pc' -exec sed -i -E \
    "s#^(prefix|exec_prefix|libdir|includedir|sharedlibdir)=/usr#\1=$SYSROOT/usr#" {} +
export PKG_CONFIG_PATH=$SYSROOT/usr/lib/x86_64-linux-gnu/pkgconfig:$SYSROOT/usr/share/pkgconfig

make -C "$TMP/src" all INCLUDES="$(pkg-config --cflags pixman-1 libdrm hyprland pangocairo \
    libinput libudev wayland-server xkbcommon) -I$SYSROOT/usr/include"
install -D -m 0755 "$TMP/src/Hyprspace.so" "$OUT"
echo "Đã cài $OUT - chạy 'hyprctl reload' để nạp."
