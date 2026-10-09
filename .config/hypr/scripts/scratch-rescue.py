#!/usr/bin/env python3
"""scratch-rescue.py: Tự động cứu các cửa sổ tài liệu / app con (file Excel, Word,
PDF, ảnh, link web...) được mở từ trong scratchpad (Viber, Discord, Spotify).
Khi click mở file trong Viber (dù ở special:viber hay special:scratch-*), app con (như ONLYOFFICE, Loupe,
Papers, Chrome...) không bị kẹt trong special workspace nữa, mà được tự động chuyển
về workspace thông thường đang hiển thị trên màn hình.
"""

import os
import re
import socket
import sys
import time
import json
import signal

UID = os.getuid()
HIS = os.environ.get('HYPRLAND_INSTANCE_SIGNATURE', '')
XRD = os.environ.get('XDG_RUNTIME_DIR', f'/run/user/{UID}')
SOCKET_PATH = f'{XRD}/hypr/{HIS}/.socket.sock'
if not os.path.exists(SOCKET_PATH):
    SOCKET_PATH = f'/tmp/hypr/{HIS}/.socket.sock'

SOCKET2_PATH = f'{XRD}/hypr/{HIS}/.socket2.sock'
if not os.path.exists(SOCKET2_PATH):
    SOCKET2_PATH = f'/tmp/hypr/{HIS}/.socket2.sock'

PID_FILE = os.path.join(XRD, "hypr-scratch-rescue.pid")
LOG_FILE = "/tmp/scratch-rescue.log"

def log(msg):
    try:
        with open(LOG_FILE, "a", encoding="utf-8") as f:
            f.write(f"[{time.strftime('%Y-%m-%d %H:%M:%S')}] {msg}\n")
    except Exception:
        pass

# 1. Các app chuyên dụng ĐƯỢC PHÉP nằm trong special workspace tương ứng
SPECIAL_ALLOW = {
    'special:viber': re.compile(r'^(viber|viberpc)$', re.IGNORECASE),
    'special:discord': re.compile(r'^(discord|vesktop|webcord)$', re.IGNORECASE),
    'special:spotify': re.compile(r'^spotify$', re.IGNORECASE),
}

# 2. Danh sách các app tài liệu / trình duyệt / media KHÔNG BAO GIỜ được kẹt trong special workspace
ALWAYS_RESCUE_CLASSES = re.compile(
    r'^(xdg-desktop-portal-gtk|ONLYOFFICE|desktopeditors|soffice\.bin|libreoffice.*|'
    r'org\.gnome\.Evince|evince|org\.gnome\.Papers|papers|okular|atril|xreader|'
    r'google-chrome.*|firefox.*|brave-browser.*|chromium.*|microsoft-edge.*|'
    r'loupe|org\.gnome\.Loupe|eog|imv|feh|mpv|vlc|totem|'
    r'org\.gnome\.Nautilus|nautilus|thunar|dolphin|file-roller|org\.gnome\.FileRoller|'
    r'gedit|gnome-text-editor|org\.gnome\.TextEditor|code.*|vscodium.*|cursor.*)$',
    re.IGNORECASE
)

def query_hypr(cmd):
    try:
        with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as s:
            s.settimeout(0.5)
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

def cmd_hypr(cmd):
    try:
        with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as s:
            s.settimeout(0.5)
            s.connect(SOCKET_PATH)
            s.sendall(cmd.encode('utf-8'))
            return s.recv(4096).decode('utf-8')
    except Exception:
        return ''

def get_active_workspace():
    monitors = query_hypr('j/monitors')
    if monitors:
        for m in monitors:
            if m.get('focused'):
                return m.get('activeWorkspace', {}).get('name', '1')
        return monitors[0].get('activeWorkspace', {}).get('name', '1')
    return '1'

def should_rescue(ws, cls, raw_addr):
    if not ws or not ws.startswith('special:'):
        return False

    # 1. Nếu là app tài liệu / văn phòng / trình duyệt / media -> luôn cứu ra ngoài!
    if ALWAYS_RESCUE_CLASSES.match(cls):
        return True

    # 2. Nếu là special workspace cố định (special:viber, special:discord, special:spotify)
    pattern = SPECIAL_ALLOW.get(ws)
    if pattern is not None:
        if ws == 'special:viber' and pattern.match(cls):
            # Nếu là cửa sổ con (xem ảnh / MediaPreview / popup) của Viber
            clients = query_hypr('j/clients')
            if clients:
                viber_windows = [c for c in clients if pattern.match(c.get('class', ''))]
                # Nếu đã có cửa sổ Viber khác đang mở, cửa sổ mới này là cửa sổ con -> cứu ra active workspace!
                for c in viber_windows:
                    c_addr = c.get('address', '').lower()
                    if c_addr not in [f'0x{raw_addr.lower()}', raw_addr.lower()]:
                        return True
        return not bool(pattern.match(cls))

    # 3. Nếu là scratchpad do stash (special:scratch-<stashed_addr>)
    if ws.startswith('special:scratch-'):
        stashed_addr = ws[len('special:scratch-'):].lower()
        # Nếu cửa sổ mới mở có address khác với cửa sổ ban đầu được stash:
        if raw_addr.lower() != stashed_addr:
            # Tra cứu class của cửa sổ được stash ban đầu
            clients = query_hypr('j/clients')
            if clients:
                for c in clients:
                    c_addr = c.get('address', '').lower()
                    if c_addr in [f'0x{stashed_addr}', stashed_addr]:
                        stashed_cls = c.get('class', '')
                        # Nếu class khác với app được stash -> chắc chắn là app con mở thêm -> cứu!
                        if stashed_cls and cls.lower() != stashed_cls.lower():
                            return True
                        break
            else:
                # Nếu không tìm thấy thông tin, nhưng class khác -> cứu
                return True

    return False

def rescue_window(addr, ws, cls):
    time.sleep(0.05)
    target_ws = get_active_workspace()
    log(f"Rescuing window {cls} ({addr}) from {ws} to workspace {target_ws}")
    
    cmd_hypr(f'dispatch movetoworkspacesilent {target_ws},address:{addr}')
    cmd_hypr(f'dispatch focuswindow address:{addr}')

    # Đóng overlay special workspace nếu đang hiển thị đè lên màn hình
    monitors = query_hypr('j/monitors')
    if monitors:
        for m in monitors:
            if m.get('focused'):
                sp = m.get('specialWorkspace', {}).get('name', '')
                if sp and sp.startswith('special:'):
                    sp_name = sp[len('special:'):]
                    cmd_hypr(f'dispatch togglespecialworkspace {sp_name}')
                break

def handle_openwindow(line):
    # Format Hyprland socket2: openwindow>>WINDOWADDRESS,WORKSPACE,CLASS,TITLE
    content = line[12:].strip()
    parts = content.split(',', 3)
    if len(parts) < 3:
        return

    raw_addr, ws, cls = parts[0], parts[1], parts[2]
    addr = '0x' + raw_addr

    if should_rescue(ws, cls, raw_addr):
        rescue_window(addr, ws, cls)

def scan_and_rescue_existing():
    clients = query_hypr('j/clients')
    if not clients:
        return
    for c in clients:
        ws = c.get('workspace', {}).get('name', '')
        cls = c.get('class', '')
        addr = c.get('address', '')
        raw_addr = addr[2:] if addr.startswith('0x') else addr
        if should_rescue(ws, cls, raw_addr):
            rescue_window(addr, ws, cls)

def handle_workspace_change(new_ws):
    if not new_ws or new_ws.startswith('special:'):
        return

    try:
        monitors = query_hypr('j/monitors')
        visible_workspaces = set()
        if monitors:
            for m in monitors:
                ws_id = m.get('activeWorkspace', {}).get('name')
                if ws_id:
                    visible_workspaces.add(str(ws_id))

        clients = query_hypr('j/clients')
        if not clients:
            return

        state_dir = os.path.join(XRD, "hypr-scratch-state")
        stashed_addrs = set()
        if os.path.exists(state_dir):
            try:
                for fname in os.listdir(state_dir):
                    if fname.endswith('.json') and fname != 'cycle_index':
                        stashed_addrs.add(fname[:-5].lower())
            except Exception:
                pass

        for c in clients:
            ws_name = str(c.get('workspace', {}).get('name', ''))
            # Bỏ qua nếu đã ở special workspace hoặc workspace đó vẫn đang hiển thị trên màn hình
            if not ws_name or ws_name.startswith('special:') or ws_name in visible_workspaces:
                continue

            # Chỉ áp dụng cho cửa sổ floating
            if not c.get('floating'):
                continue

            cls = c.get('class', '')
            addr = c.get('address', '')
            raw_addr = addr[2:].lower() if addr.startswith('0x') else addr.lower()

            home_ws = None
            if re.match(r'^(viber|viberpc)$', cls, re.IGNORECASE):
                home_ws = 'special:viber'
            elif re.match(r'^spotify$', cls, re.IGNORECASE):
                home_ws = 'special:spotify'
            elif re.match(r'^(discord|vesktop|webcord)$', cls, re.IGNORECASE):
                home_ws = 'special:discord'
            elif raw_addr in stashed_addrs:
                home_ws = f'special:scratch-{raw_addr}'

            if home_ws:
                log(f"Auto-tucking scratchpad {cls} ({addr}) from workspace {ws_name} into {home_ws}")
                cmd_hypr(f"dispatch movetoworkspacesilent {home_ws},address:{addr}")
    except Exception as e:
        log(f"Error in handle_workspace_change: {e}")

def ensure_single_instance():
    if os.path.exists(PID_FILE):
        try:
            with open(PID_FILE) as f:
                old_pid = int(f.read().strip())
            os.kill(old_pid, signal.SIGTERM)
            time.sleep(0.1)
        except (ValueError, ProcessLookupError, FileNotFoundError):
            pass
    try:
        with open(PID_FILE, "w") as f:
            f.write(str(os.getpid()))
    except Exception:
        pass

def main():
    ensure_single_instance()
    log("scratch-rescue daemon started")
    scan_and_rescue_existing()

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
                    if line.startswith('openwindow>>') or line.startswith('closewindow>>'):
                        log(f"EVENT: {line.strip()}")
                    if line.startswith('openwindow>>'):
                        handle_openwindow(line)
                    elif line.startswith('workspace>>'):
                        new_ws = line[len('workspace>>'):].strip()
                        handle_workspace_change(new_ws)
        except Exception as e:
            log(f"Error in event loop: {e}")
            time.sleep(1)

if __name__ == '__main__':
    main()
