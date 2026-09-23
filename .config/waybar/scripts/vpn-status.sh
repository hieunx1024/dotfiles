#!/bin/bash
ip4=$(ip -4 addr show tun0 2>/dev/null | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
printf '{"text": "VPN", "tooltip": "VPN dang ket noi (tun0)\\nIP: %s", "class": "connected"}\n' "$ip4"
