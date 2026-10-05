#!/usr/bin/env python3
"""scratch-rescue.py: Tự động cứu các cửa sổ tài liệu / app con (file Excel, Word,
PDF, ảnh, link web...) được mở từ trong scratchpad (Viber, Discord, Spotify).
Khi click mở file trong Viber (đang ở special:viber), app con (như ONLYOFFICE, Loupe,
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

# Chỉ định app nào ĐƯỢC PHÉP nằm trong special workspace tương ứng.
# Mọi app/cửa sổ khác mở ra trong special workspace này sẽ được tự động giải cứu ra workspace chính.
SPECIAL_ALLOW = {
    'special:viber': re.compile(r'^(viber|viberpc)$', re.IGNORECASE),
    'special:discord': re.compile(r'^(discord|vesktop|webcord)$', re.IGNORECASE),
    'special:spotify': re.compile(r'^spotify$', re.IGNORECASE),
}

def query_hypr(cmd):
    try:
        with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as s:
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

def handle_openwindow(line):
    # Format Hyprland socket2: openwindow>>WINDOWADDRESS,WORKSPACE,CLASS,TITLE
    content = line[12:].strip()
    parts = content.split(',', 3)
    if len(parts) < 3:
        return

    raw_addr, ws, cls = parts[0], parts[1], parts[2]
    addr = '0x' + raw_addr

    pattern = SPECIAL_ALLOW.get(ws)
    if pattern is not None:
        # Nếu class KHÔNG khớp với app chuyên dụng của scratchpad này -> cứu ngay!
        if not pattern.match(cls):
            target_ws = get_active_workspace()
            cmd_hypr(f'dispatch movetoworkspacesilent {target_ws},address:{addr}')
            cmd_hypr(f'dispatch focuswindow address:{addr}')

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
                    if line.startswith('openwindow>>'):
                        handle_openwindow(line)
        except Exception:
            time.sleep(1)

if __name__ == '__main__':
    main()
