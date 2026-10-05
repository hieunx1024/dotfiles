#!/usr/bin/env bash
# =============================================================================
# Universal Polkit Authentication Agent Launcher
# Multi-distro support: Ubuntu, Debian, Fedora, Arch Linux, openSUSE, Void, Alpine...
# =============================================================================

# Do not launch if another polkit agent is already running in this session
for pid in $(pgrep -f 'authentication-agent-1' 2>/dev/null); do
    if [ "$pid" != "$$" ]; then
        exit 0
    fi
done

# Candidate agent paths across various distros & desktop toolkits
CANDIDATES=(
    # Hyprland Polkit Agent (hyprpolkitagent)
    /usr/lib/hyprpolkitagent
    /usr/libexec/hyprpolkitagent
    # GNOME Polkit (Ubuntu / Debian)
    /usr/lib/policykit-1-gnome/polkit-gnome-authentication-agent-1
    # GNOME Polkit (Fedora, openSUSE, RHEL)
    /usr/libexec/polkit-gnome-authentication-agent-1
    # GNOME Polkit (Arch Linux, Void, Gentoo, Alpine)
    /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1
    /usr/lib64/polkit-gnome/polkit-gnome-authentication-agent-1
    # MATE Polkit (Fedora / Arch)
    /usr/libexec/polkit-mate-authentication-agent-1
    /usr/lib/mate-polkit/polkit-mate-authentication-agent-1
    # KDE Polkit (KF6 / KF5)
    /usr/libexec/kf6/polkit-kde-authentication-agent-1
    /usr/lib/polkit-kde-authentication-agent-1
    /usr/lib/x86_64-linux-gnu/libexec/polkit-kde-authentication-agent-1
    /usr/libexec/kf5/polkit-kde-authentication-agent-1
    # LXQt Polkit
    /usr/bin/lxqt-policykit-agent
)

for agent in "${CANDIDATES[@]}"; do
    if [ -x "$agent" ]; then
        exec "$agent"
    fi
done

# Fallback dynamic discovery if installed in a non-standard directory
FALLBACK=$(find /usr/lib* /usr/libexec -name "*authentication-agent-1" -type f -executable 2>/dev/null | head -n 1)
if [ -n "$FALLBACK" ] && [ -x "$FALLBACK" ]; then
    exec "$FALLBACK"
fi

logger -t polkit-launcher "Warning: No polkit authentication agent found on system."
