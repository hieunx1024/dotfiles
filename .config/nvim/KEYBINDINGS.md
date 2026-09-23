# ⌨️ NEOVIM CHEATSHEET & KEYBINDINGS (BẢNG THỦ THUẬT & PHÍM TẮT DÙNG TRONG NEOVIM)

> **Leader Key**: `<Space>` (Phím Cách)

---

## 1. 📂 Quản Lý File & Tìm Kiếm (FZF & Explorer)

| Phím Tắt | Chế Độ | Chức Năng | File Cấu Hình |
| :--- | :--- | :--- | :--- |
| `<leader>ff` | Normal | Tìm kiếm file trong project (FZF Files) | `lua/plugins/fzf.lua` |
| `<leader>pf` | Normal | Tìm kiếm file được Git theo dõi (Git Files) | `lua/plugins/fzf.lua` |
| `<leader>fg` | Normal | Tìm kiếm nội dung văn bản (Live Grep) | `lua/plugins/fzf.lua` |
| `<leader>fG` | Normal | Live Grep bao gồm cả file ẩn (Hidden files) | `lua/plugins/fzf.lua` |
| `<leader>fs` | Normal | FZF Grep với ô nhập từ khóa tùy chỉnh | `lua/plugins/fzf.lua` |
| `<leader>fb` | Normal | Danh sách các Buffer đang mở | `lua/plugins/fzf.lua` |
| `<leader>fh` | Normal | Tìm kiếm các thẻ trợ giúp (Help Tags) | `lua/plugins/fzf.lua` |
| `<leader>ce` | Normal | Tìm file nhanh trong thư mục hiện tại | `lua/vim-helpers.lua` |
| `<leader>vv` | Normal | Mở trình quản lý file **Oil.nvim** | `lua/plugins/oil.lua` |
| `<leader>vf` | Normal | Mở **Oil.nvim** trong cửa sổ nổi (Floating window) | `lua/plugins/oil.lua` |
| `<leader>vi` | Normal | Xem chi tiết thông tin file trong Oil | `lua/plugins/oil.lua` |
| `<leader>vt` | Normal | Hiển thị cây thư mục dạng floating window (`ShowTree`) | `lua/vim-helpers.lua` |

### 🔍 Thao tác bên trong cửa sổ Oil (`<leader>vv` / `<leader>vf`):
- `<CR>` (Enter): Mở file / Chọn mục
- `<C-t>`: Mở file trong Tab mới
- `<C-p>`: Xem trước nội dung (Preview)
- `<C-c>`: Đóng cửa sổ Oil
- `R`: Làm mới (Refresh) view
- `-`: Lùi lại thư mục cha
- `_`: Mở thư mục làm việc hiện tại (CWD)
- `` ` ``: Chuyển thư mục `cd` vào thư mục hiện tại
- `~`: Đến thư mục Home (`~`)
- `gs`: Thay đổi kiểu sắp xếp
- `gx`: Mở file bằng phần mềm hệ thống ngoài
- `H`: Ẩn / Hiện file ẩn
- `g\`: Bật / Tắt chế độ Thùng rác (Trash)
- `g?`: Xem trợ giúp chi tiết phím tắt Oil

---

## 2. ⚡ Di Chuyển Cửa Sổ & Buffer (Navigation & Buffers)

| Phím Tắt | Chế Độ | Chức Năng | File Cấu Hình |
| :--- | :--- | :--- | :--- |
| `H` | Normal | Chuyển sang Buffer bên trái (Previous Buffer) | `lua/vim-options.lua` |
| `L` | Normal | Chuyển sang Buffer bên phải (Next Buffer) | `lua/vim-options.lua` |
| `<leader>bd` | Normal | Đóng Buffer hiện tại (`bdelete`) | `lua/vim-options.lua` |
| `<C-h>` | Normal | Chuyển sang cửa sổ / Pane Tmux bên Trái | `lua/plugins/tmux-navigator.lua` |
| `<C-j>` | Normal | Chuyển sang cửa sổ / Pane Tmux bên Dưới | `lua/plugins/tmux-navigator.lua` |
| `<C-k>` | Normal | Chuyển sang cửa sổ / Pane Tmux bên Trên | `lua/plugins/tmux-navigator.lua` |
| `<C-l>` | Normal | Chuyển sang cửa sổ / Pane Tmux bên Phải | `lua/plugins/tmux-navigator.lua` |
| `<leader>T` | Normal / Term | Bật / Tắt Terminal nổi (Floating Terminal) | `lua/floating-term.lua` |
| `J` | Visual | Di chuyển dòng / khối code được chọn xuống dưới | `lua/vim-options.lua` |
| `K` | Visual | Di chuyển dòng / khối code được chọn lên trên | `lua/vim-options.lua` |
| `<leader>p` | Visual / Select | Dán (Paste) đè nội dung mà không mất bộ nhớ clipboard | `lua/vim-options.lua` |

---

## 3. 💡 LSP, Chẩn Đoán & Định Dạng Code (LSP & Diagnostics)

| Phím Tắt | Chế Độ | Chức Năng | File Cấu Hình |
| :--- | :--- | :--- | :--- |
| `K` | Normal | Hiển thị thông tin Hover (Hàm, Kiểu dữ liệu, Doc) | `lua/plugins/lsp-configs.lua` |
| `gd` | Normal | Đi đến định nghĩa (Go to Definition) | `lua/plugins/lsp-configs.lua` |
| `gD` | Normal | Đi đến khai báo (Go to Declaration) | `lua/plugins/lsp-configs.lua` |
| `gi` | Normal | Đi đến Implementation | `lua/plugins/lsp-configs.lua` |
| `gr` | Normal | Tìm tất cả các vị trí tham chiếu (References) | `lua/plugins/lsp-configs.lua` |
| `<leader>rn` | Normal | Đổi tên biến/hàm trên toàn bộ project (Rename) | `lua/plugins/lsp-configs.lua` |
| `<leader>ca` | Normal / Visual | Thực hiện Code Action (Sửa lỗi tự động, import, v.v.) | `lua/plugins/lsp-configs.lua` |
| `<leader>fm` | Normal | Format code bằng LSP | `lua/plugins/lsp-configs.lua` |
| `<leader>gf` | Normal | Format code bằng None-ls (Null-ls) | `lua/plugins/none-ls.lua` |
| `<leader>ne` | Normal | Nhảy tới lỗi tiếp theo (Next Diagnostic Error) | `lua/vim-helpers.lua` |
| `<leader>pe` | Normal | Quay lại lỗi phía trước (Prev Diagnostic Error) | `lua/vim-helpers.lua` |
| `<leader>e` | Normal | Hiển thị thông tin lỗi chi tiết trong khung nổi | `lua/vim-helpers.lua` |

---

## 4. 🐙 Git (GitSigns & Diffview)

| Phím Tắt | Chế Độ | Chức Năng | File Cấu Hình |
| :--- | :--- | :--- | :--- |
| `]h` | Normal | Nhảy đến đoạn thay đổi Git tiếp theo (Next Hunk) | `lua/plugins/gitstuff.lua` |
| `[h` | Normal | Quay lại đoạn thay đổi Git phía trước (Prev Hunk) | `lua/plugins/gitstuff.lua` |
| `<leader>hs` | Normal / Visual | Stage Hunk (Đưa đoạn code vào Staging area) | `lua/plugins/gitstuff.lua` |
| `<leader>hr` | Normal / Visual | Reset Hunk (Hủy bỏ thay đổi của đoạn code) | `lua/plugins/gitstuff.lua` |
| `<leader>hS` | Normal | Stage toàn bộ Buffer hiện tại | `lua/plugins/gitstuff.lua` |
| `<leader>hR` | Normal | Reset toàn bộ thay đổi của Buffer hiện tại | `lua/plugins/gitstuff.lua` |
| `<leader>hb` | Normal | Hiển thị thông tin Git Blame của dòng hiện tại | `lua/plugins/gitstuff.lua` |
| `<leader>hB` | Normal | Bật/Tắt hiển thị dòng Git Blame tự động | `lua/plugins/gitstuff.lua` |
| `<leader>hd` | Normal | Xem Diff của dòng/đoạn code hiện tại | `lua/plugins/gitstuff.lua` |
| `<leader>hD` | Normal | Xem Diff so với commit gần nhất (`~1`) | `lua/plugins/gitstuff.lua` |
| `ih` | Operator / Visual | Chọn nhanh khối lệnh Hunk hiện tại (Gitsigns object) | `lua/plugins/gitstuff.lua` |
| `<leader>dv` | Normal | Bật/Tắt giao diện xem Diff toàn project (**Diffview**) | `lua/plugins/gitstuff.lua` |

---

## 5. 🧪 Testing & Debugging (Neotest & DAP)

| Phím Tắt | Chế Độ | Chức Năng | File Cấu Hình |
| :--- | :--- | :--- | :--- |
| `<leader>tr` | Normal | Chạy test gần vị trí con trỏ nhất | `lua/plugins/neotest.lua` |
| `<leader>tb` | Normal | Debug test gần vị trí con trỏ bằng DAP | `lua/plugins/neotest.lua` |
| `<leader>ts` | Normal | Dừng lượt chạy test hiện tại | `lua/plugins/neotest.lua` |
| `<leader>to` | Normal | Xem kết quả test trong khung output | `lua/plugins/neotest.lua` |
| `<leader>tO` | Normal | Mở khung kết quả test và nhảy con trỏ vào | `lua/plugins/neotest.lua` |
| `<leader>tv` | Normal | Bật/Tắt bảng tổng hợp tất cả test (Summary Toggle) | `lua/plugins/neotest.lua` |
| `<leader>tp` | Normal | Chạy toàn bộ test trong file hiện tại | `lua/plugins/neotest.lua` |
| `<leader>tt` | Normal | Chạy test cụ thể dưới con trỏ (Hỗ trợ Go test) | `lua/plugins/neotest.lua` |
| `<leader>dt` | Normal | Đặt / Xóa điểm dừng Debug (Toggle Breakpoint) | `lua/plugins/debugging.lua` |
| `<leader>dc` | Normal | Bắt đầu / Tiếp tục chạy Debug (Continue) | `lua/plugins/debugging.lua` |

---

## 6. 🛠 Công Cụ & Tiện Ích Khác (Utilities & Tools)

| Phím Tắt | Chế Độ | Chức Năng | File Cấu Hình |
| :--- | :--- | :--- | :--- |
| `<leader>ut` | Normal | Bật/Tắt bảng lịch sử Undo (**Undotree**) | `lua/plugins/undo-tree.lua` |
| `<leader>uf` | Normal | Nhảy con trỏ vào bảng Undotree | `lua/plugins/undo-tree.lua` |
| `<leader>nt` | Normal | Chuyển đổi giao diện / Theme màu sắc | `lua/plugins/themes.lua` |
| `<leader>cp` | Normal | Sao chép đường dẫn tuyệt đối của file vào Clipboard | `lua/vim-helpers.lua` |
| `<leader>ob` | Normal | Mở file hiện tại trên Trình duyệt web (Chrome/Firefox) | `lua/vim-helpers.lua` |
| `<leader>nw` | Normal | Tạo một Buffer / Scratch Window mới | `lua/snipets.lua` |
| `<leader>s` | Selection | Thêm bao quanh (Surround) đoạn được chọn | `lua/plugins/surround.lua` |
| `<leader>sw` | Normal | Thêm bao quanh từ dưới con trỏ | `lua/plugins/surround.lua` |
| `<leader>sr` | Normal | Đổi hoặc xóa bao quanh của từ hiện tại | `lua/plugins/surround.lua` |
| `<leader>ts` | Selection | Đổi hoặc xóa bao quanh của đoạn text được chọn | `lua/plugins/surround.lua` |

---

## 7. 🌐 REST API & WebSocket Client

| Phím Tắt | Chế Độ | Chức Năng | File Cấu Hình |
| :--- | :--- | :--- | :--- |
| `<leader>Kt` | Normal | Gửi HTTP Request tại vị trí con trỏ (rest.nvim) | `lua/plugins/rest.lua` |
| `<leader>Ka` | Normal | Gửi tất cả HTTP Requests trong file | `lua/plugins/rest.lua` |
| `<leader>Ko` | Normal | Mở Scratchpad REST API | `lua/plugins/rest.lua` |
| `<leader>ws` | Normal | Gửi tin nhắn WebSocket (phát hiện JSON & URL) | `lua/ws.lua` |
| `<leader>wc` | Normal | Xóa toàn bộ Log hiển thị WebSocket | `lua/ws.lua` |

---

## 8. 🍎 Swift & iOS (Xcodebuild)

| Phím Tắt | Chế Độ | Chức Năng | File Cấu Hình |
| :--- | :--- | :--- | :--- |
| `<leader>xl` | Normal | Bật/Tắt Log của Xcodebuild | `lua/plugins/apple.lua` |
| `<leader>xb` | Normal | Build dự án Xcode | `lua/plugins/apple.lua` |
| `<leader>xr` | Normal | Build & Run dự án Xcode | `lua/plugins/apple.lua` |
| `<leader>xt` | Normal | Chạy bộ test Xcode | `lua/plugins/apple.lua` |
| `<leader>xT` | Normal | Chạy Test Class hiện tại | `lua/plugins/apple.lua` |
| `<leader>xd` | Normal | Chọn Simulator / Thiết bị chạy iOS | `lua/plugins/apple.lua` |
| `<leader>xp` | Normal | Chọn Workspace / Project Xcode | `lua/plugins/apple.lua` |

---

## 9. ☕ Java Development (JDTLS)

| Phím Tắt | Chế Độ | Chức Năng | File Cấu Hình |
| :--- | :--- | :--- | :--- |
| `<leader>co` | Normal | Sắp xếp & Tối ưu imports (Organize Imports) | `ftplugin/java.lua` |
| `<leader>crv` | Normal/Visual | Trích xuất Biến (Extract Variable) | `ftplugin/java.lua` |
| `<leader>crc` | Normal/Visual | Trích xuất Hằng số (Extract Constant) | `ftplugin/java.lua` |
| `<leader>crm` | Visual | Trích xuất Phương thức / Hàm (Extract Method) | `ftplugin/java.lua` |

---

## 10. 🦀 Rust Development (RustLSP)

| Phím Tắt | Chế Độ | Chức Năng | File Cấu Hình |
| :--- | :--- | :--- | :--- |
| `<leader>ca` | Normal | Code Action dành riêng cho Rust | `lua/plugins/rust.lua` |
| `K` | Normal | Hover thông tin chi tiết / Docs cho Rust | `lua/plugins/rust.lua` |
| `<leader>rd` | Normal | Chạy/Debug các khối lệnh Rust (Rust Debuggables) | `lua/plugins/rust.lua` |

---
