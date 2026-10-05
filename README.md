# Sway Dotfiles

Personal configuration for Sway Window Manager on Linux (Ubuntu/Debian, Fedora, Arch).

## Setup

```bash
git clone -b sway https://github.com/hieunx1024/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./setup.sh
```

`setup.sh` handles:
- Package installation via `apt`, `dnf`, or `pacman` depending on your distro.
- Downloading and caching JetBrainsMono Nerd Font.
- Installing `waypaper` via pipx and tmux TPM.
- Symlinking configs to `~/.config/` (existing files are backed up to `~/.dotfiles-setup-backup-<timestamp>/`).
- Launching the polkit authentication agent via `launch-polkit.sh`.

After setup finishes, log out and log back in to apply group permissions and environment variables.

### Manual steps
- `.gitconfig` is intentionally not tracked to keep machine-specific git identities.
- [`view-launcher`](https://github.com/hieunx1024/view-launcher) is a separate personal Rust project — build or install its package separately if needed.

## Managed Configurations

- **Sway**: `~/.config/sway/` (bindings, display modes, scripts)
- **Waybar**: `~/.config/waybar/` (status bar, Graphite theme)
- **SwayNC**: `~/.config/swaync/` (notification center)
- **Fuzzel**: `~/.config/fuzzel/` (app launcher)
- **Wlogout**: `~/.config/wlogout/` (power menu)
- **Waypaper**: `~/.config/waypaper/` (wallpaper manager, swaybg backend)
- **Terminal & Shell**: `~/.config/kitty/`, `.bashrc`, `.zshrc`
- **Editor & Multiplexer**: `~/.config/nvim/`, `~/.config/tmux/`
- **Input & Theming**: `~/.config/fcitx5/`, `~/.config/nwg-look/`, `~/.config/gtk-3.0/`, `~/.config/gtk-4.0/`

## Dotfiles Management

Manage changes using the `dotfiles` alias defined in `.bashrc`/`.zshrc`:

```bash
dotfiles status
dotfiles add -A
dotfiles commit -m "commit message"
dotfiles push origin sway
```

Shortcuts cheatsheet is viewable inside Sway via `$mod+i` (`~/.config/sway/shortcut.md`).
