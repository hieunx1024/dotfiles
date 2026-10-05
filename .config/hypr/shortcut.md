# Hyprland - Phím tắt

## Ứng dụng
- `Super+Enter` — terminal (kitty)
- `Super+D` — launcher (fuzzel)
- `Super+B` — firefox · `Super+E` — nautilus
- `Super+V` — lịch sử clipboard
- `Super+Tab` — overview mọi workspace trên mọi màn (Hyprspace) · vuốt 3 ngón dọc
  - trong overview: `←/→` hoặc `h/l` đổi workspace (màn có chuột), `Enter`/`Esc` thoát; click workspace để chuyển, kéo cửa sổ thả sang workspace khác
- `Super+N` — trung tâm thông báo
- `Super+I` — xem file này
- `Super+Q` — đóng cửa sổ · `Super+Shift+Q` — kill -9

## Cửa sổ & workspace
- `Super+H/J/K/L` hoặc mũi tên — đổi focus; khi ở trong group, `H/L` hoặc `←/→` chuyển tab trước
- `Super+Shift+H/J/K/L` — di chuyển cửa sổ
- `Super+1..0` — sang workspace · `Super+Shift+1..0` — chuyển cửa sổ sang workspace
- `Super+Ctrl+←/→` — workspace trước/sau · vuốt 3 ngón ngang
- `Super+F` — fullscreen · `Super+M` — maximize
- `Super+W` — gộp nhóm (tab) · `Super+X` — đổi hướng chia
- `Super+Shift+Space` — floating
- `Super+R` — chế độ resize (hjkl/mũi tên, Esc để thoát)
- `Super+chuột trái/phải` — kéo/resize cửa sổ

## Scratchpad
- `Super+Shift+-` — cất cửa sổ · `Super+-` — hiện/chuyển vòng/ẩn các cửa sổ scratchpad
- `Super+Ctrl+-` — lấy cửa sổ ra và khôi phục workspace, tiled/floating, kích thước cũ
- `Super+Ctrl+D/S/V` — hiện/ẩn và focus riêng Discord / Spotify / Viber

## Hệ thống
- `Super+Shift+E` — menu nguồn (wlogout)
- `Super+Ctrl+L` — khóa màn hình
- `Super+Alt+S` — ngủ
- `Super+Shift+C` — reload Hyprland · `Super+Ctrl+B` — ẩn/hiện waybar · `Super+Shift+B` — bật/tắt chế độ minimal của waybar
- `Super+Shift+T` — chọn theme · `Super+Shift+U` — đổi nhanh theme sáng/tối
- `Super+Shift+P` — chế độ màn hình (chỉ laptop / chỉ màn ngoài / mở rộng trái-phải-trên / mirror)
- `Super+Shift+N` — night light · `Super+Ctrl+N` — menu night light
- `Super+Shift+A` — đổi thiết bị âm thanh
- `Super+Shift+S` — chụp vùng vào clipboard · `Print` — chụp toàn màn (swappy)

## Neovim (Leader key: `Space`)
- `Space + ?` — mở full bảng tra cứu phím tắt Neovim (`KEYBINDINGS.md`)
- `H` / `L` — chuyển nhanh tab/buffer trước / sau
- `Space + bd` — đóng buffer hiện tại (giữ nguyên layout split)
- `Space + ff` — tìm file trong project (FZF) · `Space + pf` — tìm file Git
- `Space + fg` — tìm kiếm nội dung (Live Grep) · `Space + fb` — danh sách buffer
- `Space + vv` / `Space + vf` — mở trình quản lý file Oil (toàn màn hình / popup nổi)
- `Space + T` / `Ctrl+t` — bật / ẩn Terminal nổi (Floating Terminal)
- `Ctrl+h/j/k/l` — di chuyển mượt mà giữa các split Neovim & pane Tmux
- `gd` — nhảy tới định nghĩa hàm/biến · `K` — xem tài liệu hover
- `Space + ca` — gợi ý sửa lỗi / Code Actions · `Space + rn` — đổi tên biến (Rename)
- `Space + e` — xem popup chi tiết lỗi LSP · `Space + ce` — copy thông báo lỗi
- `J` / `K` (Visual mode) — kéo trượt khối code lên / xuống
- `Space + p` (Visual mode) — dán đè mà không bị mất dữ liệu trong clipboard

