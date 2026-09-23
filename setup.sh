#!/usr/bin/env bash
# setup.sh - Cài đặt môi trường Sway đầy đủ trên máy Ubuntu mới, dựa trên dotfiles branch "ubuntu".
# Chạy sau khi đã clone repo: ./setup.sh

set -e

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[0;33m'; BLUE='\033[0;34m'; BOLD='\033[1m'; NC='\033[0m'
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${BLUE}${BOLD}=== Cài đặt dotfiles Sway (Ubuntu) từ $DOTFILES_DIR ===${NC}"

# 1. Cài gói apt cần thiết
echo -e "${YELLOW}[1/5]${NC} Cài gói apt..."
APT_PACKAGES=(
    sway waybar sway-notification-center kitty nautilus nwg-look
    fuzzel wlogout
    fcitx5 fcitx5-config-qt fcitx5-bamboo fcitx5-frontend-gtk3 fcitx5-frontend-gtk4 fcitx5-frontend-qt5 fcitx5-frontend-qt6
    grim slurp swappy wl-clipboard
    brightnessctl playerctl wlsunset
    tmux htop
    pavucontrol blueman
    jq rsync fastfetch
    network-manager
    pipx
)
sudo apt update
sudo apt install -y "${APT_PACKAGES[@]}"

# 2. Cài app qua pipx (không có trong apt)
echo -e "${YELLOW}[2/5]${NC} Cài waypaper qua pipx..."
pipx ensurepath
pipx install waypaper || pipx upgrade waypaper

# Đưa .desktop + icon của waypaper ra thư mục chuẩn để app launcher (fuzzel) thấy được
WAYPAPER_VENV="$HOME/.local/share/pipx/venvs/waypaper"
if [ -d "$WAYPAPER_VENV" ]; then
    mkdir -p "$HOME/.local/share/applications" "$HOME/.local/share/icons/hicolor/scalable/apps"
    cp -f "$WAYPAPER_VENV/share/applications/waypaper.desktop" "$HOME/.local/share/applications/" 2>/dev/null || true
    cp -f "$WAYPAPER_VENV/share/icons/hicolor/scalable/apps/waypaper.svg" "$HOME/.local/share/icons/hicolor/scalable/apps/" 2>/dev/null || true
fi

echo -e "${YELLOW}${BOLD}Lưu ý:${NC} 'view-launcher' là project riêng của bạn (không có trong apt) — tự build/cài .deb riêng."

# 3. Symlink các thư mục .config vào repo
echo -e "${YELLOW}[3/5]${NC} Tạo symlink .config..."
# Thư mục thuộc sở hữu riêng của dotfiles - symlink nguyên thư mục
CONFIG_DIRS=(fcitx fcitx5 fuzzel nwg-look sway swaync waybar waypaper kitty nvim gtk-3.0 gtk-4.0 wlogout tmux)
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
        # Đã là symlink, kiểm tra đúng đích chưa
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

for d in "${SHARED_DIRS[@]}"; do
    SRC_DIR="$DOTFILES_DIR/.config/$d"
    DST_DIR="$HOME/.config/$d"
    [ -d "$SRC_DIR" ] || continue

    # An toàn: nếu cả thư mục từng bị symlink nhầm (vd chạy bản script cũ), gỡ ra
    # thành thư mục thật trước khi symlink từng file - tránh vòng lặp symlink tự trỏ vào chính nó.
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

# 4. Symlink các dotfile ở top-level $HOME (trừ .gitconfig - giữ danh tính git riêng của máy)
echo -e "${YELLOW}[4/5]${NC} Tạo symlink dotfile top-level..."
TOP_FILES=(.bashrc .gtkrc-2.0 .Xresources)
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

echo -e "${YELLOW}${BOLD}Bỏ qua:${NC} .gitconfig (giữ danh tính git hiện có của máy, không ghi đè)."

# 5. Thêm user vào group video (để brightnessctl hoạt động không cần sudo)
echo -e "${YELLOW}[5/5]${NC} Thêm user vào group 'video'..."
if ! groups "$USER" | grep -q '\bvideo\b'; then
    sudo usermod -aG video "$USER"
    echo -e "${YELLOW}Cần đăng xuất/đăng nhập lại (hoặc reboot) để group 'video' có hiệu lực.${NC}"
else
    echo "  -> Đã có sẵn trong group video."
fi

echo -e "${GREEN}${BOLD}=== Hoàn tất! ===${NC}"
echo "Đăng xuất và đăng nhập lại vào phiên Sway để áp dụng đầy đủ (PATH, group video, autostart)."
[ -d "$BACKUP_DIR" ] && echo -e "${YELLOW}Các file/thư mục bị trùng đã backup vào: $BACKUP_DIR${NC}"
