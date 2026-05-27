# Sway Window Manager Dotfiles

Kho lưu trữ cấu hình môi trường Sway Window Manager và các công cụ phát triển liên quan. Repository được quản lý bằng phương pháp Bare Git Repository sạch sẽ và tối giản.

## Khôi phục trên máy mới

Chạy lệnh duy nhất sau trên terminal của máy mới (yêu cầu cài đặt sẵn Git):

```bash
curl -sSL https://raw.githubusercontent.com/hieunx1024/dotfiles/main/bootstrap.sh | bash
```

*Lưu ý: Kịch bản khôi phục sẽ tự động di chuyển các tệp cấu hình mặc định bị trùng tên vào thư mục sao lưu `~/.dotfiles-backup-<timestamp>/` trước khi thực hiện checkout.*

## Danh sách cấu hình được quản lý

*   **Sway**: `~/.config/sway/` (Cấu hình chính, phím tắt, hiển thị)
*   **SwayNC**: `~/.config/swaync/` (Trung tâm thông báo)
*   **Waybar**: `~/.config/waybar/` (Thanh trạng thái)
*   **Fuzzel**: `~/.config/fuzzel/` (Menu ứng dụng)
*   **Waypaper**: `~/.config/waypaper/` (Trình đổi hình nền)
*   **Neovim**: `~/.config/nvim/` (Cấu hình trình soạn thảo code)
*   **Tmux**: `~/.config/tmux/` (Trình quản lý phiên terminal)
*   **Kitty**: `~/.config/kitty/` (Terminal emulator)
*   **GTK Themes & Yay**: `~/.config/nwg-look/`, `~/.config/gtk-3.0/`, `~/.config/gtk-4.0/`, `~/.config/yay/`
*   **Bộ gõ**: `~/.config/fcitx/`, `~/.config/fcitx5/`
*   **Shell profiles**: `.bashrc`, `.bashrc_custom`, `.bash_profile`, `.zshrc`, `.zprofile`, `.zshenv`
*   **Git**: `.gitconfig`
*   **Khác**: `.gtkrc-2.0`, `.Xresources`

## Hướng dẫn sử dụng lệnh dotfiles

Sử dụng lệnh `dotfiles` (alias trỏ tới bare repo) để quản lý cấu hình thay vì lệnh `git` thông thường:

### Xem trạng thái thay đổi
```bash
dotfiles status
```

### Thêm tệp cấu hình mới
```bash
dotfiles add -f <đường_dẫn_tệp_hoặc_thư_mục>
```

### Lưu thay đổi cục bộ
```bash
dotfiles commit -m "Mô tả thay đổi"
```

### Đồng bộ lên GitHub
```bash
dotfiles push origin main
```
