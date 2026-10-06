#!/bin/bash
# Build + cài plugin hyprtasking (lưới 3x3 fullscreen overview, kéo thả cửa sổ giữa workspace)
# tương thích Hyprland 0.53.3, KHÔNG cần sudo.
set -euo pipefail

COMMIT=${COMMIT:-40e6f615c6e2f7f016d1ee6cfa34668edbeb0cc1}
PATCH=$(dirname "$(readlink -f "$0")")/hyprtasking-click-to-exit.patch
OUT=$HOME/.local/lib/hyprland/hyprtasking.so
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

git clone -q https://github.com/raybbian/hyprtasking.git "$TMP/src"
git -C "$TMP/src" checkout -q "$COMMIT"
if [ -f "$PATCH" ]; then
    git -C "$TMP/src" apply "$PATCH"
fi

DEVS="hyprland-dev libpixman-1-dev libpango1.0-dev libudev-dev libinput-dev libcairo2-dev
libdrm-dev libwayland-dev libxkbcommon-dev libaquamarine-dev libhyprutils-dev libhyprlang-dev
libhyprgraphics-dev libhyprcursor-dev libharfbuzz-dev libfreetype-dev libfontconfig-dev
libgles-dev libegl-dev libgl-dev libglx-dev x11proto-dev libx11-dev libxcb1-dev libxrender-dev
libxext-dev libpng-dev libfribidi-dev libthai-dev libdatrie-dev libxft-dev libxau-dev
libxdmcp-dev libxcb-render0-dev libxcb-shm0-dev libxcb-composite0-dev libxcb-errors-dev
libxcb-icccm4-dev libxcb-res0-dev libxcb-xfixes0-dev libxcb-shape0-dev libgraphite2-dev
libbrotli-dev libbz2-dev libicu-dev libice-dev libsm-dev libpciaccess-dev xtrans-dev
libevdev-dev libmtdev-dev libwacom-dev libgudev-1.0-dev"

SYSROOT=$TMP/sysroot
mkdir -p "$TMP/debs" "$SYSROOT"
(cd "$TMP/debs" && apt-get download -q $DEVS >/dev/null)
for d in "$TMP"/debs/*.deb; do
    dpkg-deb -x "$d" "$SYSROOT"
done

find "$SYSROOT" -name '*.pc' -exec sed -i -E \
    "s#^(prefix|exec_prefix|libdir|includedir|sharedlibdir)=/usr#\1=$SYSROOT/usr#" {} +

export PKG_CONFIG_PATH=$SYSROOT/usr/lib/x86_64-linux-gnu/pkgconfig:$SYSROOT/usr/share/pkgconfig
CFLAGS=$(pkg-config --cflags pixman-1 libdrm hyprland pangocairo libinput libudev wayland-server xkbcommon)

SOURCES=$(find "$TMP/src/src" -name "*.cpp")
g++ -shared -fPIC --no-gnu-unique -std=c++23 -O2 -Wno-narrowing \
    $CFLAGS -I$SYSROOT/usr/include \
    $SOURCES \
    -o "$TMP/hyprtasking.so"

install -D -m 0755 "$TMP/hyprtasking.so" "$OUT"
echo "Đã cài $OUT - chạy 'hyprctl reload' để nạp."
