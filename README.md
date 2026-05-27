# 💻 Cấu hình Dotfiles cá nhân (SwayWM & Công cụ liên quan)

Kho lưu trữ (repository) này chứa tất cả các tệp cấu hình giao diện người dùng, terminal, và công cụ phát triển của tôi trên hệ điều hành Linux sử dụng **Sway Window Manager**.

Hệ thống được quản lý cực kỳ sạch sẽ bằng cách sử dụng phương pháp **Bare Git Repository**, giúp lưu trữ trực tiếp các tệp tin từ thư mục `$HOME` mà không cần sử dụng symbolic links (symlinks) hay các công cụ cài thêm phức tạp.

---

## 🚀 Khôi phục trên máy mới chỉ với 1 Dòng lệnh!

Khi cài đặt lại máy hoặc chuyển sang thiết bị mới, bạn chỉ cần mở terminal, cài đặt `git` và chạy lệnh duy nhất dưới đây để đồng bộ hóa hoàn hảo tất cả cấu hình:

```bash
curl -sSL https://raw.githubusercontent.com/hieunx1024/dotfiles/main/bootstrap.sh | bash
```

> [!NOTE]
> Script `bootstrap.sh` sẽ tự động:
> 1. Clone cấu hình này về thư mục ẩn `~/.dotfiles`.
> 2. Tự động sao lưu các tệp tin mặc định trùng lặp hiện có trên máy mới vào `~/.dotfiles-backup-xxxxxx/` để tránh lỗi đè dữ liệu.
> 3. Checkout các tệp cấu hình ra thư mục `$HOME`.
> 4. Cấu hình sẵn alias `dotfiles` trong các file cấu hình Shell (`.bashrc` / `.zshrc`) của bạn.

---

## 📂 Danh sách các cấu hình được theo dõi

### Giao diện người dùng (Sway & UI Core)
*   **Sway**: `~/.config/sway/` (Window manager chính, phím tắt, cấu hình màn hình và khởi động)
*   **SwayNC**: `~/.config/swaync/` (Sway Notification Center - Trung tâm thông báo và điều khiển nhanh)
*   **Waybar**: `~/.config/waybar/` (Status bar động và tùy biến giao diện)
*   **Waypaper**: `~/.config/waypaper/` (Ứng dụng GUI đổi và chọn hình nền)
*   **Fuzzel**: `~/.config/fuzzel/` (Trình tìm kiếm và chạy ứng dụng tối giản, nhanh gọn)
*   **nwg-look** & **GTK Themes**: `~/.config/nwg-look/`, `~/.config/gtk-3.0/`, `~/.config/gtk-4.0/` (Quản lý giao diện, font chữ, icon)

### Công cụ Terminal & Lập trình
*   **Neovim (nvim)**: `~/.config/nvim/` (Trình soạn thảo code chính của tôi)
*   **Tmux**: `~/.config/tmux/` (Trình quản lý phiên làm việc đa cửa sổ trên terminal)
*   **Kitty**: `~/.config/kitty/` (Terminal Emulator hiệu năng cao hỗ trợ GPU render)
*   **Yay**: `~/.config/yay/` (Cấu hình bộ quản lý gói AUR trên Arch Linux)
*   **Fcitx / Fcitx5**: `~/.config/fcitx/`, `~/.config/fcitx5/` (Bộ gõ tiếng Việt)

### Cấu hình Hệ thống & Môi trường Shell
*   **Bash**: `.bashrc`, `.bashrc_custom`, `.bash_profile`
*   **Zsh**: `.zshrc`, `.zprofile`, `.zshenv`
*   **Git**: `.gitconfig` (Thông tin và cài đặt Git cá nhân)
*   **Các tài nguyên khác**: `.gtkrc-2.0`, `.Xresources`

---

## 🛠️ Hướng dẫn sử dụng lệnh `dotfiles`

Do cấu hình ở dạng bare repository, bạn sẽ sử dụng lệnh `dotfiles` thay thế cho lệnh `git` thông thường khi muốn chỉnh sửa hoặc thêm cấu hình:

### 1. Kiểm tra trạng thái thay đổi
Xem các tệp cấu hình nào đã được chỉnh sửa:
```bash
dotfiles status
```

### 2. Thêm tệp cấu hình mới
Để thêm hoặc cập nhật một tệp cấu hình vào kho lưu trữ:
```bash
dotfiles add ~/.config/ten_thu_muc/
# Hoặc ép thêm tệp đang bị ignore:
dotfiles add -f ~/.bashrc
```

### 3. Lưu lại thay đổi (Commit)
```bash
dotfiles commit -m "Cập nhật: thay đổi cấu hình phím tắt sway"
```

### 4. Đẩy lên GitHub
```bash
dotfiles push
```

---

## 🌟 Hướng dẫn đẩy repository này lên GitHub lần đầu tiên (Dành cho hieunx1024)

1. Truy cập vào tài khoản GitHub của bạn và tạo một repository mới tên là `dotfiles` (Lưu ý: **KHÔNG** tích chọn thêm README, .gitignore hay LICENSE).
2. Chạy lần lượt các lệnh sau trong terminal của bạn để đẩy toàn bộ dotfiles cục bộ lên GitHub:

```bash
# Thêm remote liên kết với repo GitHub của bạn
dotfiles remote add origin git@github.com:hieunx1024/dotfiles.git

# Đặt tên nhánh chính là main
dotfiles branch -M main

# Đẩy dữ liệu lên GitHub
dotfiles push -u origin main
```

*(Nếu bạn muốn sử dụng giao thức HTTPS thay vì SSH, hãy đổi đường dẫn origin thành `https://github.com/hieunx1024/dotfiles.git`)*
