# Sway Window Manager Dotfiles (Ubuntu)

Kho lưu trữ cấu hình môi trường Sway Window Manager và các công cụ phát triển liên quan.

> **Branch `ubuntu`** — dành riêng cho máy chạy Ubuntu (apt, PipeWire/wpctl). Branch `main` là bản cũ cho Arch, không còn được cập nhật song song với branch này.

## Khôi phục trên máy Ubuntu mới

```bash
git clone -b ubuntu https://github.com/hieunx1024/dotfiles.git ~/Desktop/dotfiles
cd ~/Desktop/dotfiles
./setup.sh
```

`setup.sh` tự động: cài toàn bộ gói apt/pipx cần thiết, tạo symlink `.config` + dotfile top-level, thêm user vào group `video` (cho `brightnessctl`). File/thư mục bị trùng tên trên máy sẽ được backup vào `~/.dotfiles-setup-backup-<timestamp>/` trước khi ghi đè.

Sau khi chạy xong, **đăng xuất và đăng nhập lại** (hoặc reboot) để PATH và group mới có hiệu lực đầy đủ.

### Không tự động được (cần làm tay)

*   **`.gitconfig`** — cố tình bỏ qua, giữ nguyên danh tính git riêng của từng máy.
*   **`view-launcher`** — project Rust cá nhân, không có trong kho apt nào, cần tự build/cài `.deb` riêng.

## Danh sách cấu hình được quản lý

*   **Sway**: `~/.config/sway/` (cấu hình chính, phím tắt, hiển thị)
*   **SwayNC**: `~/.config/swaync/` (trung tâm thông báo)
*   **Waybar**: `~/.config/waybar/` (thanh trạng thái)
*   **Fuzzel**: `~/.config/fuzzel/` (menu ứng dụng)
*   **Wlogout**: `~/.config/wlogout/` (menu nguồn)
*   **Waypaper**: `~/.config/waypaper/` (trình đổi hình nền, backend `swaybg`)
*   **Neovim**: `~/.config/nvim/`
*   **Tmux**: `~/.config/tmux/`
*   **Kitty**: `~/.config/kitty/`
*   **GTK Themes**: `~/.config/nwg-look/`, `~/.config/gtk-3.0/`, `~/.config/gtk-4.0/`
*   **Bộ gõ**: `~/.config/fcitx/`, `~/.config/fcitx5/`
*   **Autostart / Environment**: `~/.config/autostart/`, `~/.config/environment.d/` (symlink từng file, không đụng entry của app khác)
*   **Shell**: `.bashrc`
*   **Khác**: `.gtkrc-2.0`, `.Xresources`

Không quản lý qua dotfiles (cần cấu hình riêng từng máy): `.gitconfig`, `.zshrc`/`.zprofile`/`.zshenv` (không dùng zsh trên setup này).

## Hướng dẫn sử dụng lệnh dotfiles

Sử dụng lệnh `dotfiles` (alias trỏ tới repo tại `~/Desktop/dotfiles`) để quản lý cấu hình thay vì lệnh `git` thông thường:

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
dotfiles push origin ubuntu
```
