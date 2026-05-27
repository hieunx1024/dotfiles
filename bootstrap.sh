#!/usr/bin/env bash

# bootstrap.sh - Một dòng lệnh để khôi phục toàn bộ dotfiles của bạn!
# Hướng dẫn: curl -sSL https://raw.githubusercontent.com/hieunx/dotfiles/main/bootstrap.sh | bash

set -e

# Mã màu ANSI để làm đẹp giao diện terminal
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

echo -e "${BLUE}${BOLD}======================================================${NC}"
echo -e "${BLUE}${BOLD}   Hệ thống Khôi phục Dotfiles tự động của hieunx     ${NC}"
echo -e "${BLUE}${BOLD}======================================================${NC}"

# 1. Kiểm tra Git đã cài đặt chưa
if ! command -v git &> /dev/null; then
    echo -e "${RED}${BOLD}[LỖI]${NC} Git chưa được cài đặt trên hệ thống này!"
    echo -e "Vui lòng cài đặt Git trước khi tiếp tục (ví dụ: 'sudo pacman -S git' hoặc 'sudo apt install git')."
    exit 1
fi

# 2. Khai báo các đường dẫn cần thiết
REPO_URL="https://github.com/hieunx1024/dotfiles.git"
DOTFILES_DIR="$HOME/.dotfiles"
BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%Y%m%d%H%M%S)"

# Định nghĩa lệnh Git quản lý dotfiles
function dotfiles() {
    /usr/bin/git --git-dir="$DOTFILES_DIR" --work-tree="$HOME" "$@"
}

# 3. Khởi tạo và Clone Bare Repository
if [ -d "$DOTFILES_DIR" ]; then
    echo -e "${YELLOW}[THÔNG BÁO]${NC} Thư mục bare repo '$DOTFILES_DIR' đã tồn tại."
    echo -e "Đang thực hiện kéo cấu hình mới nhất..."
else
    echo -e "${YELLOW}[1/4]${NC} Đang clone Bare repository từ GitHub về $DOTFILES_DIR..."
    git clone --bare "$REPO_URL" "$DOTFILES_DIR"
fi

# 4. Cấu hình local để ẩn các tệp chưa được theo dõi trong $HOME
echo -e "${YELLOW}[2/4]${NC} Thiết lập cấu hình ẩn các tệp không thuộc dotfiles..."
dotfiles config --local status.showUntrackedFiles no

# 5. Tiến hành Checkout dotfiles ra thư mục $HOME
echo -e "${YELLOW}[3/4]${NC} Đang tiến hành checkout các tệp cấu hình ra $HOME..."
if dotfiles checkout 2>&1 | grep -E "would be overwritten by checkout"; then
    echo -e "${YELLOW}[CẢNH BÁO]${NC} Phát hiện một số tệp cấu hình mặc định bị trùng lặp trên máy mới."
    echo -e "Hệ thống đang tự động tạo thư mục sao lưu tại: ${BLUE}$BACKUP_DIR${NC}"
    mkdir -p "$BACKUP_DIR"
    
    # Lấy danh sách các tệp bị xung đột và di chuyển chúng sang thư mục backup
    dotfiles checkout 2>&1 | grep -E "^\s+\." | awk '{print $1}' | while read -r file; do
        if [ -f "$HOME/$file" ] || [ -L "$HOME/$file" ]; then
            # Tạo thư mục con tương ứng trong thư mục backup nếu cần
            mkdir -p "$BACKUP_DIR/$(dirname "$file")"
            mv "$HOME/$file" "$BACKUP_DIR/$file"
            echo -e "  -> Đã di chuyển: ~/$file sang backup."
        fi
    done
    
    # Thử checkout lại sau khi đã di chuyển các tệp xung đột
    echo -e "${YELLOW}[THÔNG TIN]${NC} Đang thử checkout lại..."
    dotfiles checkout
fi

echo -e "${GREEN}${BOLD}[THÀNH CÔNG]${NC} Đã checkout thành công tất cả tệp cấu hình!"

# 6. Thiết lập alias "dotfiles" cho Shell hiện tại và tương lai
echo -e "${YELLOW}[4/4]${NC} Đang cấu hình alias 'dotfiles' cho hệ thống..."

ALIAS_LINE="alias dotfiles='/usr/bin/git --git-dir=\$HOME/.dotfiles/ --work-tree=\$HOME'"

# Thêm vào .bashrc nếu chưa có
if [ -f "$HOME/.bashrc" ]; then
    if ! grep -q "alias dotfiles=" "$HOME/.bashrc"; then
        echo -e "\n# Dotfiles Management Alias\n$ALIAS_LINE" >> "$HOME/.bashrc"
        echo -e "  -> Đã thêm alias vào ~/.bashrc"
    fi
fi

# Thêm vào .zshrc nếu chưa có
if [ -f "$HOME/.zshrc" ]; then
    if ! grep -q "alias dotfiles=" "$HOME/.zshrc"; then
        echo -e "\n# Dotfiles Management Alias\n$ALIAS_LINE" >> "$HOME/.zshrc"
        echo -e "  -> Đã thêm alias vào ~/.zshrc"
    fi
fi

echo -e "${GREEN}${BOLD}======================================================${NC}"
echo -e "${GREEN}${BOLD}  QUY TRÌNH THIẾT LẬP HOÀN TẤT CHỈ VỚI 1 LỆNH!       ${NC}"
echo -e "${GREEN}${BOLD}======================================================${NC}"
echo -e "Bây giờ bạn có thể mở terminal mới và dùng lệnh: ${BLUE}${BOLD}dotfiles status${NC}"
echo -e "Chúc bạn có trải nghiệm tuyệt vời với giao diện Sway của mình!"
