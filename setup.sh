#!/usr/bin/env bash
# setup.sh - Cài đặt môi trường Hyprland đa nền tảng (Ubuntu, Debian, Fedora, Arch Linux)
# Chạy sau khi đã clone repo: ./setup.sh

set -e

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[0;33m'; BLUE='\033[0;34m'; BOLD='\033[1m'; NC='\033[0m'
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Nhận diện Distro
if [ -f /etc/os-release ]; then
    . /etc/os-release
    DISTRO_ID="${ID:-unknown}"
    DISTRO_LIKE="${ID_LIKE:-$DISTRO_ID}"
else
    DISTRO_ID="unknown"
    DISTRO_LIKE="unknown"
fi

echo -e "${BLUE}${BOLD}=== Cài đặt dotfiles Hyprland từ $DOTFILES_DIR ===${NC}"
echo -e "${BLUE}${BOLD}=== Phát hiện hệ điều hành: ${NAME:-$DISTRO_ID} ($DISTRO_ID) ===${NC}"

# 1. Cài đặt các gói hệ thống theo distro
echo -e "${YELLOW}[1/8]${NC} Cài đặt gói hệ thống..."
if [[ "$DISTRO_LIKE" == *"debian"* ]] || [[ "$DISTRO_LIKE" == *"ubuntu"* ]]; then
    sudo apt update
    sudo apt install -y \
        build-essential git \
        hyprland hypridle hyprlock waybar sway-notification-center kitty nautilus nwg-look \
        fuzzel wlogout \
        fcitx5 fcitx5-config-qt fcitx5-bamboo fcitx5-frontend-gtk3 fcitx5-frontend-gtk4 fcitx5-frontend-qt5 fcitx5-frontend-qt6 \
        grim slurp swappy wl-clipboard cliphist \
        brightnessctl playerctl wlsunset \
        tmux htop \
        pavucontrol blueman wireplumber \
        jq rsync fastfetch python3 python3-pip python3-venv \
        network-manager \
        policykit-1-gnome \
        pipx curl tar fonts-font-awesome
elif [[ "$DISTRO_LIKE" == *"fedora"* ]] || [[ "$DISTRO_ID" == "fedora" ]]; then
    sudo dnf install -y \
        gcc-c++ git \
        hyprland hypridle hyprlock waybar kitty nautilus nwg-look \
        fuzzel wlogout \
        fcitx5 fcitx5-configtool fcitx5-bamboo fcitx5-gtk fcitx5-qt \
        grim slurp swappy wl-clipboard cliphist \
        brightnessctl playerctl wlsunset \
        tmux htop \
        pavucontrol blueman wireplumber \
        jq rsync fastfetch python3 python3-pip python3-virtualenv \
        NetworkManager \
        polkit-gnome \
        pipx curl tar fontawesome-fonts
    if ! command -v swaync &>/dev/null; then
        echo "  -> Đang kiểm tra/cài đặt swaync qua copr..."
        sudo dnf copr enable -y erikreider/swaync 2>/dev/null || true
        sudo dnf install -y swaync 2>/dev/null || true
    fi
elif [[ "$DISTRO_LIKE" == *"arch"* ]] || [[ "$DISTRO_ID" == "arch" ]]; then
    sudo pacman -S --needed --noconfirm \
        base-devel git \
        hyprland hypridle hyprlock waybar swaync kitty nautilus nwg-look \
        fuzzel wlogout \
        fcitx5 fcitx5-configtool fcitx5-bamboo fcitx5-gtk fcitx5-qt \
        grim slurp swappy wl-clipboard cliphist \
        brightnessctl playerctl wlsunset \
        tmux htop \
        pavucontrol blueman wireplumber \
        jq rsync fastfetch python python-pip \
        networkmanager \
        polkit-gnome \
        python-pipx curl tar ttf-font-awesome
else
    echo -e "${YELLOW}Cảnh báo: Chưa có danh sách gói tự động cho distro: $DISTRO_ID. Bỏ qua bước cài gói.${NC}"
fi

# 2. Cài app qua pipx (không có trong repo chính thức hoặc cần bản mới nhất)
echo -e "${YELLOW}[2/8]${NC} Cài waypaper qua pipx..."
pipx ensurepath
pipx install waypaper || pipx upgrade waypaper

# Đưa .desktop + icon của waypaper ra thư mục chuẩn để app launcher (fuzzel) thấy được
WAYPAPER_VENV="$HOME/.local/share/pipx/venvs/waypaper"
if [ -d "$WAYPAPER_VENV" ]; then
    mkdir -p "$HOME/.local/share/applications" "$HOME/.local/share/icons/hicolor/scalable/apps"
    cp -f "$WAYPAPER_VENV/share/applications/waypaper.desktop" "$HOME/.local/share/applications/" 2>/dev/null || true
    cp -f "$WAYPAPER_VENV/share/icons/hicolor/scalable/apps/waypaper.svg" "$HOME/.local/share/icons/hicolor/scalable/apps/" 2>/dev/null || true
fi

# 3. Cài JetBrainsMono Nerd Font (để hiển thị icon Waybar, SwayNC, Terminal)
echo -e "${YELLOW}[3/8]${NC} Kiểm tra JetBrainsMono Nerd Font..."
if ! fc-list : family | grep -iq "JetBrainsMono Nerd Font"; then
    echo "  -> Đang tải JetBrainsMono Nerd Font..."
    FONT_DIR="$HOME/.local/share/fonts/JetBrainsMono"
    mkdir -p "$FONT_DIR"
    curl -fLo /tmp/JetBrainsMono.tar.xz https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz
    tar -xf /tmp/JetBrainsMono.tar.xz -C "$FONT_DIR"
    rm -f /tmp/JetBrainsMono.tar.xz
    fc-cache -f
    echo "  -> Đã cài đặt JetBrainsMono Nerd Font thành công."
else
    echo "  -> JetBrainsMono Nerd Font đã có sẵn."
fi

# 4. Sao chép hình nền mẫu và cài đặt tmux plugin manager (tpm)
echo -e "${YELLOW}[4/8]${NC} Thiết lập tài nguyên bổ trợ (wallpapers, tmux tpm)..."
if [ -d "$DOTFILES_DIR/wallpapers" ]; then
    mkdir -p "$HOME/Pictures/wallpapers"
    cp -n "$DOTFILES_DIR/wallpapers/"* "$HOME/Pictures/wallpapers/" 2>/dev/null || true
fi

if [ ! -d "$HOME/.config/tmux/plugins/tpm" ]; then
    git clone https://github.com/tmux-plugins/tpm "$HOME/.config/tmux/plugins/tpm" 2>/dev/null || true
fi

echo -e "${YELLOW}${BOLD}Lưu ý:${NC} 'view-launcher' (https://github.com/hieunx1024/view-launcher) là project riêng — tự build/cài nếu cần."

# 5. Symlink các thư mục .config vào repo
echo -e "${YELLOW}[5/8]${NC} Tạo symlink .config..."
# Thư mục thuộc sở hữu riêng của dotfiles hypr - symlink nguyên thư mục
CONFIG_DIRS=(fcitx fcitx5 hypr browser-themes nwg-look nvim gtk-3.0 gtk-4.0 tmux)
# Thư mục dùng chung với app khác (XDG autostart/environment.d) - chỉ symlink từng file bên trong,
# tránh nuốt mất entry của app khác không thuộc dotfiles
SHARED_DIRS=(autostart environment.d)

BACKUP_DIR="$HOME/.dotfiles-setup-backup-$(date +%Y%m%d%H%M%S)"
mkdir -p "$HOME/.config"

for d in "${CONFIG_DIRS[@]}"; do
    SRC="$DOTFILES_DIR/.config/$d"
    DST="$HOME/.config/$d"
    [ -d "$SRC" ] || continue

    if [ -L "$DST" ]; then
        if [ "$(readlink -f "$DST")" = "$(readlink -f "$SRC")" ]; then
            continue
        fi
        rm "$DST"
    elif [ -e "$DST" ]; then
        mkdir -p "$BACKUP_DIR/.config"
        echo "  -> Backup $DST vào $BACKUP_DIR/.config/$d"
        mv "$DST" "$BACKUP_DIR/.config/$d"
    fi
    ln -s "$SRC" "$DST"
    echo "  -> Linked: ~/.config/$d"
done

# Shortcut cheatsheet link
[ -f "$DOTFILES_DIR/.config/hypr/shortcut.md" ] && ln -sfn "$DOTFILES_DIR/.config/hypr/shortcut.md" "$HOME/.config/shortcut.md"

for d in "${SHARED_DIRS[@]}"; do
    SRC_DIR="$DOTFILES_DIR/.config/$d"
    DST_DIR="$HOME/.config/$d"
    [ -d "$SRC_DIR" ] || continue

    if [ -L "$DST_DIR" ]; then
        rm "$DST_DIR"
    fi
    mkdir -p "$DST_DIR"

    for f in "$SRC_DIR"/*; do
        [ -e "$f" ] || continue
        name="$(basename "$f")"
        target="$DST_DIR/$name"

        if [ -L "$target" ] && [ "$(readlink -f "$target")" = "$(readlink -f "$f")" ]; then
            continue
        fi
        if [ -e "$target" ] || [ -L "$target" ]; then
            mkdir -p "$BACKUP_DIR/.config/$d"
            mv "$target" "$BACKUP_DIR/.config/$d/$name"
            echo "  -> Backup $target vào $BACKUP_DIR/.config/$d/$name"
        fi
        ln -s "$f" "$target"
        echo "  -> Linked: ~/.config/$d/$name"
    done
done

# 6. Symlink các dotfile ở top-level $HOME (trừ .gitconfig)
echo -e "${YELLOW}[6/8]${NC} Tạo symlink dotfile top-level..."
TOP_FILES=(.bashrc .zshrc .gtkrc-2.0 .Xresources)
for f in "${TOP_FILES[@]}"; do
    SRC="$DOTFILES_DIR/$f"
    DST="$HOME/$f"
    [ -f "$SRC" ] || continue

    if [ -L "$DST" ] && [ "$(readlink -f "$DST")" = "$(readlink -f "$SRC")" ]; then
        continue
    fi
    if [ -e "$DST" ] || [ -L "$DST" ]; then
        mkdir -p "$BACKUP_DIR"
        mv "$DST" "$BACKUP_DIR/$f"
        echo "  -> Backup $DST vào $BACKUP_DIR/$f"
    fi
    ln -s "$SRC" "$DST"
    echo "  -> Linked: ~/$f"
done

# dbus service override
for SRC in "$DOTFILES_DIR"/.local/share/dbus-1/services/*.service; do
    [ -f "$SRC" ] || continue
    DST="$HOME/.local/share/dbus-1/services/$(basename "$SRC")"
    if [ -e "$DST" ] || [ -L "$DST" ]; then
        echo "  -> Giữ nguyên: ~/.local/share/dbus-1/services/$(basename "$SRC") (đã tồn tại)"
        continue
    fi
    mkdir -p "$(dirname "$DST")"
    ln -s "$SRC" "$DST"
    echo "  -> Linked: ~/.local/share/dbus-1/services/$(basename "$SRC")"
done

# 7. Cấu hình quyền phần cứng (chỉ cần thiết trên Ubuntu/Debian)
if [[ "$DISTRO_LIKE" == *"debian"* ]] || [[ "$DISTRO_LIKE" == *"ubuntu"* ]]; then
    echo -e "${YELLOW}[7/8]${NC} Kiểm tra group 'video' (Ubuntu/Debian)..."
    if ! groups "$USER" | grep -q '\bvideo\b'; then
        sudo usermod -aG video "$USER"
        echo -e "${YELLOW}Cần đăng xuất/đăng nhập lại (hoặc reboot) để group 'video' có hiệu lực.${NC}"
    else
        echo "  -> Đã có sẵn trong group video."
    fi
else
    echo -e "${YELLOW}[7/8]${NC} Bỏ qua group 'video' ($DISTRO_ID quản lý quyền thiết bị qua systemd-logind/seat tự động)."
fi

# 8. Build plugin hyprtasking (Overview 3x3 kéo thả cửa sổ)
echo -e "${YELLOW}[8/8]${NC} Kiểm tra/Build plugin hyprtasking (Overview 3x3)..."
if [ ! -f "$HOME/.local/lib/hyprland/hyprtasking.so" ]; then
    if [[ "$DISTRO_LIKE" == *"debian"* ]] || [[ "$DISTRO_LIKE" == *"ubuntu"* ]]; then
        echo "  -> Đang tự động build hyprtasking.so..."
        bash "$DOTFILES_DIR/.config/hypr/scripts/build-hyprtasking.sh" || echo -e "${YELLOW}Chưa thể tự động build hyprtasking. Bạn có thể tự chạy sau: ~/.config/hypr/scripts/build-hyprtasking.sh${NC}"
    else
        echo -e "${YELLOW}Lưu ý: Trên $DISTRO_ID, vui lòng build plugin hyprtasking bằng ~/.config/hypr/scripts/build-hyprtasking.sh hoặc hyprpm.${NC}"
    fi
else
    echo "  -> Plugin hyprtasking.so đã có sẵn."
fi

echo -e "${GREEN}${BOLD}=== Hoàn tất! ===${NC}"
echo "Đăng xuất và đăng nhập lại vào phiên Hyprland để áp dụng đầy đủ (PATH, group video, autostart)."
[ -d "$BACKUP_DIR" ] && echo -e "${YELLOW}Các file/thư mục bị trùng đã backup vào: $BACKUP_DIR${NC}"

