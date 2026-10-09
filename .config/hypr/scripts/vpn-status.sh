#!/bin/bash
# VPN status checker for Waybar

# Fast check mode for exec-if
if [ "$1" = "--check" ]; then
    if timeout 1.5s ip -o link show up 2>/dev/null | grep -qE ': (tun|tap|wg|tailscale|ppp)[0-9a-zA-Z_-]*:'; then
        exit 0
    fi
    if timeout 1.5s nmcli -t -f TYPE connection show --active 2>/dev/null | grep -qE '^(vpn|wireguard)'; then
        exit 0
    fi
    exit 1
fi

# Query active VPN interface & IP for exec
vpn_dev=$(timeout 1.5s ip -o link show up 2>/dev/null | awk -F': ' '{print $2}' | grep -E '^(tun|tap|wg|tailscale|ppp)' | head -n1)
vpn_name="$vpn_dev"

if [ -z "$vpn_dev" ]; then
    vpn_nm=$(timeout 1.5s nmcli -t -f NAME,TYPE,DEVICE connection show --active 2>/dev/null | grep -E ':(vpn|wireguard):' | head -n1)
    if [ -n "$vpn_nm" ]; then
        vpn_name=$(echo "$vpn_nm" | cut -d: -f1)
        vpn_dev=$(echo "$vpn_nm" | cut -d: -f3)
    fi
fi

if [ -n "$vpn_name" ]; then
    ip4=""
    if [ -n "$vpn_dev" ] && [ "$vpn_dev" != "--" ]; then
        ip4=$(ip -4 addr show "$vpn_dev" 2>/dev/null | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | head -n1)
    fi
    [ -z "$ip4" ] && ip4="Đã kết nối"
    printf '{"text": "󰒃", "tooltip": "󰒃 VPN đang hoạt động: %s\\n󰩟 IP: %s", "class": "connected"}\n' "$vpn_name" "$ip4"
else
    printf '{"text": "", "class": "disconnected"}\n'
fi
