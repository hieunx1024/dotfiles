# dotfiles

Personal Linux dotfiles for Wayland compositors (Sway & Hyprland), supporting Ubuntu/Debian, Fedora, and Arch.

The repository uses dedicated branches for each environment to keep configurations isolated:

| Branch | Compositor | Description |
|---|---|---|
| [`sway`](https://github.com/hieunx1024/dotfiles/tree/sway) | Sway WM | Standard i3-style workflow, lightweight, rock-solid. |
| [`hypr`](https://github.com/hieunx1024/dotfiles/tree/hypr) | Hyprland | Modern animations, custom daemons, self-contained app configs. |

---

## Quickstart

Clone the branch you need:

### Sway
```bash
git clone -b sway https://github.com/hieunx1024/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./setup.sh
```

### Hyprland
```bash
git clone -b hypr https://github.com/hieunx1024/dotfiles.git ~/.dotfiles-hypr
cd ~/.dotfiles-hypr
./setup.sh
```

`setup.sh` detects your package manager (`apt`, `dnf`, `pacman`), installs packages, sets up fonts, symlinks configs into `~/.config/`, and configures the polkit agent.

Note: `.gitconfig` is kept machine-local. [`view-launcher`](https://github.com/hieunx1024/view-launcher) is an optional personal Rust project that can be built separately if needed.

---

## Dual Setup via Git Worktree

To run both Sway and Hyprland side-by-side on the same machine:

```bash
git clone -b sway https://github.com/hieunx1024/dotfiles.git ~/.dotfiles
git -C ~/.dotfiles worktree add ~/.dotfiles-hypr hypr

~/.dotfiles/setup.sh
~/.dotfiles-hypr/setup.sh
```

- Sway uses `~/.config/sway/` and default paths in `~/.config/`.
- Hyprland keeps its configs isolated under `~/.config/hypr/` (`waybar`, `apps/`, `scripts/`).
- Neovim, Tmux, Fcitx5, and shell configs (`.bashrc`, `.zshrc`) are shared and kept identical between both branches.

---

## Management Aliases

- `dotfiles`: Manage Sway worktree
- `dotfiles-hypr`: Manage Hyprland worktree
