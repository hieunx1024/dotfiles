#!/usr/bin/env python3
import os
import sys
import json
import time
import socket
import subprocess

LOOKUP = {
    'google-chrome': 'Chrome',
    'chromium': 'Chromium',
    'firefox': 'Firefox',
    'brave-browser': 'Brave',
    'brave': 'Brave',
    'microsoft-edge': 'Edge',
    'edge': 'Edge',
    'tor browser': 'Tor',
    'kitty': 'Terminal',
    'alacritty': 'Terminal',
    'foot': 'Terminal',
    'antigravity': 'Antigravity',
    'code': 'VS Code',
    'cursor': 'Cursor',
    'vscodium': 'VSCodium',
    'jetbrains-idea': 'IntelliJ',
    'jetbrains-datagrip': 'DataGrip',
    'jetbrains-pycharm': 'PyCharm',
    'jetbrains-webstorm': 'WebStorm',
    'jetbrains-clion': 'CLion',
    'jetbrains-goland': 'GoLand',
    'jetbrains-rustrover': 'RustRover',
    'jetbrains-rider': 'Rider',
    'jetbrains-phpstorm': 'PhpStorm',
    'dbeaver': 'DBeaver',
    'postman': 'Postman',
    'spotify': 'Spotify',
    'obsidian': 'Obsidian',
    'claude': 'Claude',
    'chatgpt': 'ChatGPT',
    'org.telegram.desktop': 'Telegram',
    'telegram': 'Telegram',
    'discord': 'Discord',
    'vesktop': 'Discord',
    'webcord': 'Discord',
    'viber': 'Viber',
    'zalo': 'Zalo',
    'slack': 'Slack',
    'onlyoffice': 'ONLYOFFICE',
    'desktopeditors': 'ONLYOFFICE',
    'org.gnome.Nautilus': 'Files',
    'nautilus': 'Files',
    'thunar': 'Files',
    'gnome-calculator': 'Calculator',
}

def clean_name(cls):
    if not cls:
        return ""
    cls_lower = cls.lower()
    for k, v in LOOKUP.items():
        if k.lower() in cls_lower:
            return v
    if cls_lower.startswith('jetbrains-'):
        return cls[10:].capitalize()
    if '.' in cls:
        last = cls.split('.')[-1]
        for k, v in LOOKUP.items():
            if k.lower() in last.lower():
                return v
        return last if not last.islower() else last.capitalize()
    return cls if not cls.islower() else cls.capitalize()

def get_state():
    try:
        act_raw = subprocess.check_output(['hyprctl', 'activewindow', '-j'], stderr=subprocess.DEVNULL)
        act = json.loads(act_raw.decode('utf-8'))
    except Exception:
        return None

    if not act or not act.get('address'):
        return None

    act_addr = act.get('address')
    grouped = act.get('grouped', [])

    if grouped and len(grouped) > 1:
        try:
            clients_raw = subprocess.check_output(['hyprctl', 'clients', '-j'], stderr=subprocess.DEVNULL)
            clients = json.loads(clients_raw.decode('utf-8'))
            addr_map = {c['address']: c for c in clients}
        except Exception:
            addr_map = {}

        items = []
        for addr in grouped:
            c = addr_map.get(addr)
            if c:
                name = clean_name(c.get('class', ''))
                is_active = (addr == act_addr)
                items.append((name, is_active))
        if items:
            return items

    # Single window (not grouped)
    name = clean_name(act.get('class', ''))
    if name:
        return [(name, True)]
    return None

def format_output(state):
    if not state:
        return json.dumps({"text": "", "class": "empty"})

    # If single window:
    if len(state) == 1:
        name = state[0][0]
        return json.dumps({"text": name, "class": "active"})

    # If grouped:
    parts = []
    for name, is_active in state:
        if is_active:
            parts.append(f"<span fgcolor='#4a4a4a'>\ue0b6</span><span bgcolor='#4a4a4a' fgcolor='#ffffff'><b> {name} </b></span><span fgcolor='#4a4a4a'>\ue0b4</span>")
        else:
            parts.append(f"<span fgcolor='#9c9a92'>{name}</span>")

    text = "  ".join(parts)
    return json.dumps({"text": text, "class": "grouped"})

def main():
    # Print initial state
    print(format_output(get_state()), flush=True)

    # Listen to socket2 events
    his = os.environ.get('HYPRLAND_INSTANCE_SIGNATURE', '')
    xrd = os.environ.get('XDG_RUNTIME_DIR', f'/run/user/{os.getuid()}')
    sock_path = f'{xrd}/hypr/{his}/.socket2.sock'

    if not os.path.exists(sock_path):
        sock_path = f'/tmp/hypr/{his}/.socket2.sock'

    while True:
        try:
            if not os.path.exists(sock_path):
                time.sleep(1)
                continue

            with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as s:
                s.connect(sock_path)
                f = s.makefile('r', encoding='utf-8')
                while True:
                    line = f.readline()
                    if not line:
                        break
                    # Event triggered
                    if any(line.startswith(ev) for ev in [
                        'activewindow>>', 'activewindowv2>>', 'closewindow>>',
                        'openwindow>>', 'movewindow>>', 'changefloatingmode>>',
                        'focusedmon>>', 'workspace>>'
                    ]):
                        print(format_output(get_state()), flush=True)
        except Exception:
            time.sleep(1)
            print(format_output(get_state()), flush=True)

if __name__ == '__main__':
    main()
