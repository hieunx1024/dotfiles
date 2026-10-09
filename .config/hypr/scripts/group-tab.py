#!/usr/bin/env python3
import os
import sys
import json
import time
import socket

INDEX = int(sys.argv[1]) if len(sys.argv) > 1 else 1
UID = os.getuid()
HIS = os.environ.get('HYPRLAND_INSTANCE_SIGNATURE', '')
XRD = os.environ.get('XDG_RUNTIME_DIR', f'/run/user/{UID}')

SOCKET_PATH = f'{XRD}/hypr/{HIS}/.socket.sock'
if not os.path.exists(SOCKET_PATH):
    SOCKET_PATH = f'/tmp/hypr/{HIS}/.socket.sock'

SOCKET2_PATH = f'{XRD}/hypr/{HIS}/.socket2.sock'
if not os.path.exists(SOCKET2_PATH):
    SOCKET2_PATH = f'/tmp/hypr/{HIS}/.socket2.sock'

LOOKUP = {
    'google-chrome': 'Chrome',
    'chromium': 'Chromium',
    'firefox': 'Firefox',
    'firefox_firefox': 'Firefox',
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

CACHE_FILE = f'/dev/shm/hypr_grouptab_{UID}.json'

def query_hypr(cmd):
    try:
        with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as s:
            s.settimeout(0.4)
            s.connect(SOCKET_PATH)
            s.sendall(cmd.encode('utf-8'))
            resp = b''
            while True:
                chunk = s.recv(4096)
                if not chunk:
                    break
                resp += chunk
            return json.loads(resp.decode('utf-8'))
    except Exception:
        return None

current_state = {'type': 'none', 'active_addr': '', 'tabs': []}

def refresh_state():
    global current_state
    # Check if another tab recently queried and cached the state (within 60ms)
    try:
        if os.path.exists(CACHE_FILE):
            st = os.stat(CACHE_FILE)
            if time.time() - st.st_mtime < 0.06:
                with open(CACHE_FILE, 'r', encoding='utf-8') as f:
                    current_state = json.load(f)
                    return
    except Exception:
        pass

    act = query_hypr('j/activewindow')
    if not act or not act.get('address'):
        current_state = {'type': 'none', 'active_addr': '', 'tabs': []}
    else:
        act_addr = act.get('address')
        grouped = act.get('grouped', [])

        if grouped and len(grouped) > 1:
            clients = query_hypr('j/clients') or []
            addr_map = {c['address']: c for c in clients}
            tabs = []
            for addr in grouped:
                c = addr_map.get(addr)
                if c:
                    tabs.append({
                        'addr': addr,
                        'name': clean_name(c.get('class', '')),
                        'title': c.get('title', '')
                    })
            current_state = {
                'type': 'grouped',
                'active_addr': act_addr,
                'tabs': tabs
            }
        else:
            name = clean_name(act.get('class', ''))
            current_state = {
                'type': 'single',
                'active_addr': act_addr,
                'tabs': [{'addr': act_addr, 'name': name, 'title': act.get('title', '')}]
            }

    # Save to shared RAM cache for sibling tabs
    try:
        with open(CACHE_FILE, 'w', encoding='utf-8') as f:
            json.dump(current_state, f)
    except Exception:
        pass

def format_tab(tab_idx):
    stype = current_state.get('type', 'none')
    tabs = current_state.get('tabs', [])
    act_addr = current_state.get('active_addr', '')

    if stype == 'none' or not tabs:
        return json.dumps({"text": "", "class": "empty", "tooltip": ""})

    if stype == 'single':
        if tab_idx == 1:
            tab = tabs[0]
            return json.dumps({
                "text": tab['name'],
                "class": "single",
                "tooltip": tab['title']
            })
        return json.dumps({"text": "", "class": "empty", "tooltip": ""})

    # Grouped mode
    if tab_idx <= len(tabs):
        tab = tabs[tab_idx - 1]
        is_active = (tab['addr'] == act_addr)
        cls = "active" if is_active else "inactive"
        return json.dumps({
            "text": tab['name'],
            "class": cls,
            "tooltip": tab['title']
        })

    return json.dumps({"text": "", "class": "empty", "tooltip": ""})

def main():
    refresh_state()
    print(format_tab(INDEX), flush=True)

    while True:
        try:
            if not os.path.exists(SOCKET2_PATH):
                time.sleep(1)
                continue

            with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as s:
                s.connect(SOCKET2_PATH)
                f = s.makefile('r', encoding='utf-8')
                while True:
                    line = f.readline()
                    if not line:
                        break

                    # Fast path: active window address changed (switching tabs within group)
                    if line.startswith('activewindowv2>>'):
                        raw_addr = line[16:].strip()
                        addr = '0x' + raw_addr
                        known_addrs = [t['addr'] for t in current_state.get('tabs', [])]
                        if addr in known_addrs:
                            if current_state['active_addr'] != addr:
                                current_state['active_addr'] = addr
                                print(format_tab(INDEX), flush=True)
                            continue
                        else:
                            refresh_state()
                            print(format_tab(INDEX), flush=True)
                            continue

                    # Structure change events: need full refresh
                    if any(line.startswith(ev) for ev in [
                        'closewindow>>', 'openwindow>>', 'movewindow>>',
                        'changefloatingmode>>', 'focusedmon>>', 'workspace>>',
                        'destroyworkspace>>', 'createworkspace>>', 'fullscreen>>',
                        'moveintoalias>>'
                    ]):
                        refresh_state()
                        print(format_tab(INDEX), flush=True)
        except BrokenPipeError:
            sys.exit(0)
        except Exception:
            time.sleep(1)
            try:
                refresh_state()
                print(format_tab(INDEX), flush=True)
            except (BrokenPipeError, Exception):
                sys.exit(0)

if __name__ == '__main__':
    try:
        main()
    except BrokenPipeError:
        sys.exit(0)
