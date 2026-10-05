# Sway Keybindings Cheatsheet

## Cơ bản
- `Super+Return` — mở terminal (kitty)
- `Super+Q` — đóng cửa sổ
- `Super+Shift+Q` — ép đóng cửa sổ bị treo (force kill -9)
- `Super+D` — app launcher (fuzzel)
- `Ctrl+Alt+Space` — view-launcher
- `Super+B` — mở Firefox
- `Super+E` — mở Nautilus (file manager)
- `Super+V` — mở lịch sử Clipboard (cliphist + fuzzel)
- `Super+I` — mở cheatsheet này (nvim -R)

## Reload / Hệ thống
- `Super+Shift+C` — reload sway
- `Super+Shift+T` — đổi theme waybar
- `Super+Shift+U` — toggle theme sáng/tối (GTK/portal)
- `Super+Shift+E` — power menu (wlogout)
- `Super+Shift+P` — chọn chế độ hiển thị màn hình
- `Super+Ctrl+L` — khóa màn hình
- `Super+Alt+S` — khóa màn hình rồi suspend
- `Super+Ctrl+B` — reload waybar
- `Super+Shift+B` — bật/tắt chế độ minimal của waybar (giống swaybar mặc định)
- Gập máy khi cắm màn ngoài: Chế độ Clamshell (tắt màn laptop, dồn workspace sang màn ngoài; mở máy tự phục hồi)

## Focus & di chuyển cửa sổ
- `Super+h/j/k/l` hoặc `Super+←/↓/↑/→` — focus theo hướng
- `Super+Shift+h/j/k/l` hoặc `Super+Shift+←/↓/↑/→` — di chuyển cửa sổ

## Workspace
- `Super+1..0` — chuyển tới workspace 1-10
- `Super+Shift+1..0` — đưa cửa sổ tới workspace 1-10
- `Super+Ctrl+←/→` — workspace trước/sau
- Vuốt 3 ngón trái/phải (touchpad) — chuyển workspace

## Layout
- `Super+S` — layout stacking
- `Super+W` — layout tabbed
- `Super+X` — toggle split
- `Super+F` — fullscreen
- `Super+M` — toggle tabbed/split + gaps
- `Super+Shift+Space` — toggle floating
- `Super+A` — focus parent
- `Super+R` — vào resize mode (h/j/k/l hoặc mũi tên để resize, Enter/Esc thoát)

## Scratchpad
- `Super+Shift+-` — đưa cửa sổ đang focus vào scratchpad
- `Super+-` — hiện cửa sổ gần nhất từ scratchpad
- `Super+Ctrl+-` — đưa cửa sổ ra khỏi scratchpad hẳn (về workspace hiện tại)
- `Super+Ctrl+D` — toggle Discord (scratchpad)
- `Super+Ctrl+S` — toggle Spotify (scratchpad)
- `Super+Ctrl+V` — toggle Viber (scratchpad)

## Cửa sổ & Overview
- `Super+Tab` — window switcher (nhóm theo workspace, có icon)
- `Super+N` — toggle notification center (swaync)

## Screenshot
- `Print` — chụp toàn màn hình, mở bằng swappy
- `Super+Shift+S` — chụp vùng chọn, copy vào clipboard

## Âm thanh / Độ sáng / Night mode
- Phím vật lý Volume Up/Down/Mute, Mic Mute — chuẩn
- Phím vật lý Brightness Up/Down — chuẩn
- `Super+Shift+N` — toggle night mode (bật/tắt lọc ánh sáng xanh wlsunset)
- `Super+Ctrl+N` — menu chọn nhiệt độ màu Night Light (fuzzel)
- `Super+Shift+A` — toggle audio output/input

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

## Máy ảo Windows 11 (KVM/virsh)
- `virsh start win11 && virt-manager --show-domain-console win11 &` — Bật & mở thẳng màn hình Win 11
- `virsh shutdown win11` — Tắt máy ảo an toàn
- `sudo virsh destroy win11` — Ép tắt máy ảo ngay (khi bị đơ/treo)
- `virsh managedsave win11` — Ngủ đông máy ảo (tiết kiệm 100% pin & giải phóng RAM)
- `virsh suspend win11` / `virsh resume win11` — Tạm dừng / Tiếp tục máy ảo
- `sudo systemctl restart libvirtd` — Sửa lỗi kẹt kết nối QEMU/KVM
