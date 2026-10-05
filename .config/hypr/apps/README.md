# Cấu hình app RIÊNG của Hyprland

Bản sao đầy đủ cấu hình kitty, fuzzel, swaync, wlogout, waypaper cho Hyprland. Sửa thoải mái ở đây
(font, bố cục, màu, theme, hình nền...): **không ảnh hưởng sway**. Hyprland không đọc/ghi
`~/.config/{kitty,fuzzel,swaync,wlogout,waypaper,gtk-3.0,gtk-4.0}` (thuộc sway, branch `ubuntu`).

| App      | Cách Hyprland dùng bản riêng                                                          |
|----------|---------------------------------------------------------------------------------------|
| kitty    | `env KITTY_CONFIG_DIRECTORY` trong hyprland.conf -> `kitty/kitty.conf`                 |
| fuzzel   | `bin/fuzzel` (đầu PATH của Hyprland) thêm `--config fuzzel/fuzzel.ini`                 |
| waypaper | `bin/waypaper` thêm `--config-file waypaper/config.ini --state-file waypaper/state.ini` |
| swaync   | swaync.service (drop-in `session-style.conf` bên sway) dùng `swaync/style.css` + `config.json` khi XDG_CURRENT_DESKTOP=Hyprland |
| wlogout  | `wlogout -l wlogout/layout -C wlogout/style.css` trong hyprland.conf                   |
| GTK/icon | chỉ gsettings; `~/.config/session-theme` lưu riêng cho từng phiên                     |

Theme đang chọn (`kitty/current-theme.conf`, `fuzzel/theme.ini`, `swaync/colors.css`,
`wlogout/colors.css`) do `scripts/theme-selector.sh` sinh, không commit. Hình nền đang dùng nằm
trong `waypaper/state.ini` (không commit).

Lưu ý: đừng đổi theme GTK bằng nwg-look trong Hyprland (nó ghi `~/.config/gtk-3.0` của sway) -
dùng Super+Shift+T.
