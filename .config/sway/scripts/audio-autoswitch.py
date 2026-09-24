#!/usr/bin/env python3
"""Tự động chuyển audio output sang thiết bị vừa kết nối (tai nghe dây / Bluetooth).
Chỉ phản ứng khi có sự kiện KẾT NỐI MỚI - không ép lại mỗi vòng lặp, để không
đè lên lựa chọn thủ công (Super+Shift+A) giữa 2 lần sự kiện.
"""

import json
import os
import signal
import subprocess
import time

PID_FILE = "/tmp/sway-audio-autoswitch.pid"


def ensure_single_instance():
    if os.path.exists(PID_FILE):
        try:
            with open(PID_FILE) as f:
                old_pid = int(f.read().strip())
            os.kill(old_pid, signal.SIGTERM)
            time.sleep(0.1)
        except (ValueError, ProcessLookupError, FileNotFoundError):
            pass
    with open(PID_FILE, "w") as f:
        f.write(str(os.getpid()))

CARD_NAME = "alsa_card.pci-0000_07_00.6"
PROFILE_HP = "HiFi (Headphones, Mic1, Mic2)"
PROFILE_SPK = "HiFi (Mic1, Mic2, Speaker)"
POLL_INTERVAL = 2


def notify(title, body, icon):
    subprocess.run(["notify-send", title, body, "-i", icon])


def wpctl(*args):
    subprocess.run(["wpctl", *args], capture_output=True)


def apply_fallback(card_id, spk_index, hp_index, hp_plugged, bt_sinks):
    """Chọn thiết bị tốt nhất còn lại theo thứ tự ưu tiên: Bluetooth > Tai nghe dây > Loa (chót)."""
    if bt_sinks:
        any_bt_id = next(iter(bt_sinks.values()))
        wpctl("set-default", str(any_bt_id))
        notify("Audio Output", "Chuyển sang Tai nghe Bluetooth", "audio-headphones")
    elif hp_plugged and card_id is not None and hp_index is not None:
        wpctl("set-profile", str(card_id), str(hp_index))
        notify("Audio Output", "Chuyển sang Tai nghe dây", "audio-headphones")
    elif card_id is not None and spk_index is not None:
        wpctl("set-profile", str(card_id), str(spk_index))
        notify("Audio Output", "Chuyển sang Loa Laptop", "audio-speakers")


def get_state():
    dump = json.loads(subprocess.run(["pw-dump"], capture_output=True, text=True).stdout)

    card_id = None
    hp_available = "no"
    hp_index = None
    spk_index = None
    current_profile = ""
    bt_sinks = {}  # node.name -> id

    for obj in dump:
        info = obj.get("info") or {}
        props = info.get("props") or {}

        if props.get("device.name") == CARD_NAME:
            card_id = obj["id"]
            params = info.get("params") or {}
            for p in params.get("EnumProfile", []):
                if p.get("name") == PROFILE_HP:
                    hp_index = p.get("index")
                    hp_available = p.get("available")
                elif p.get("name") == PROFILE_SPK:
                    spk_index = p.get("index")
            profile_list = params.get("Profile") or [{}]
            current_profile = profile_list[0].get("name", "")

        if props.get("media.class") == "Audio/Sink" and str(props.get("node.name", "")).startswith("bluez_output"):
            bt_sinks[props.get("node.name")] = obj["id"]

    return {
        "card_id": card_id,
        "hp_plugged": hp_available == "yes",
        "hp_index": hp_index,
        "spk_index": spk_index,
        "current_profile": current_profile,
        "bt_sinks": bt_sinks,
    }


def main():
    prev_hp_plugged = None
    prev_bt_names = None

    while True:
        try:
            state = get_state()
        except Exception:
            time.sleep(POLL_INTERVAL)
            continue

        card_id = state["card_id"]
        hp_plugged = state["hp_plugged"]
        bt_names = set(state["bt_sinks"].keys())

        if prev_hp_plugged is None:
            # Lần đầu chạy: chỉ ghi nhận trạng thái, không tự chuyển gì cả
            prev_hp_plugged = hp_plugged
            prev_bt_names = bt_names
            time.sleep(POLL_INTERVAL)
            continue

        # Tai nghe dây vừa CẮM VÀO
        if hp_plugged and not prev_hp_plugged and card_id is not None and state["hp_index"] is not None:
            wpctl("set-profile", str(card_id), str(state["hp_index"]))
            notify("Audio Output", "Tự động chuyển sang Tai nghe dây", "audio-headphones")

        # Tai nghe dây vừa RÚT RA -> fallback: còn Bluetooth thì dùng BT, không thì mới về Loa
        elif (not hp_plugged) and prev_hp_plugged:
            apply_fallback(card_id, state["spk_index"], state["hp_index"], hp_plugged=False, bt_sinks=state["bt_sinks"])

        # Có thiết bị Bluetooth MỚI kết nối
        new_bt = bt_names - prev_bt_names
        if new_bt:
            new_sink_id = state["bt_sinks"][next(iter(new_bt))]
            wpctl("set-default", str(new_sink_id))
            notify("Audio Output", "Tự động chuyển sang Tai nghe Bluetooth", "audio-headphones")

        # Thiết bị Bluetooth vừa NGẮT hết -> fallback: còn tai nghe dây thì dùng tai dây, không thì mới về Loa
        removed_bt = prev_bt_names - bt_names
        if removed_bt and not bt_names:
            apply_fallback(card_id, state["spk_index"], state["hp_index"], hp_plugged=hp_plugged, bt_sinks={})

        prev_hp_plugged = hp_plugged
        prev_bt_names = bt_names
        time.sleep(POLL_INTERVAL)


if __name__ == "__main__":
    ensure_single_instance()
    main()
