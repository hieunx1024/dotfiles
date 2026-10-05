# Hyprland Dotfiles

Personal configuration for Hyprland compositor on Linux (Ubuntu/Debian, Fedora, Arch).

This branch is completely self-contained. All Hyprland-specific configs and app overrides live inside `~/.config/hypr/` so they never clash with Sway or default system paths.

## Setup

```bash
git clone -b hypr https://github.com/hieunx1024/dotfiles.git ~/.dotfiles-hypr
cd ~/.dotfiles-hypr
./setup.sh
```

`setup.sh` handles:
- Package installation via `apt`, `dnf`, or `pacman`.
- Downloading and caching JetBrainsMono Nerd Font.
- Installing `waypaper` via pipx and tmux TPM.
- Symlinking `~/.config/hypr`, `~/.config/browser-themes`, and common tools (`nvim`, `tmux`, `fcitx5`, `.bashrc`, `.zshrc`).
- Universal polkit authentication launcher via `launch-polkit.sh`.

After setup finishes, log out and select the Hyprland session.

### Manual steps
- `.gitconfig` is intentionally ignored to preserve local git credentials.
- [`view-launcher`](https://github.com/hieunx1024/view-launcher) is a separate personal Rust project.

## Directory Structure

Hyprland isolates all app configurations under its own directory:

- `~/.config/hypr/hyprland.conf`: Main compositor configuration, rules, keybindings.
- `~/.config/hypr/waybar/`: Dedicated Waybar configs (Graphite, Minimal, Full).
- `~/.config/hypr/apps/`: Dedicated configs for `kitty`, `fuzzel`, `swaync`, `wlogout`, `waypaper`.
- `~/.config/hypr/scripts/`: Helper daemons and utilities (audio switcher, scratchpad rescue daemon, discrete tab-grouping, night mode, power profiles).
- Common tools: `~/.config/nvim/`, `~/.config/tmux/`, `~/.config/fcitx5/`, `~/.config/nwg-look/`.

## Dotfiles Management

Manage changes using the `dotfiles-hypr` alias:

```bash
dotfiles-hypr status
dotfiles-hypr add -A
dotfiles-hypr commit -m "commit message"
dotfiles-hypr push origin hypr
```

Shortcuts cheatsheet is viewable inside Hyprland via `$mod+i` (`~/.config/hypr/shortcut.md`).
