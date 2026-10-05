#!/usr/bin/env python3
"""Chuyển đổi Loa laptop / Tai nghe dây / Tai nghe Bluetooth (Super+Shift+A).
Dùng pw-dump + wpctl (PipeWire thuần) thay cho pactl (không có trên máy này)."""

import json
import time
import subprocess

CARD_NAME = "alsa_card.pci-0000_07_00.6"
PROFILE_HP = "HiFi (Headphones, Mic1, Mic2)"
PROFILE_SPK = "HiFi (Mic1, Mic2, Speaker)"


def notify(title, body, icon):
    subprocess.run(["notify-send", title, body, "-i", icon])


def wpctl(*args):
    subprocess.run(["wpctl", *args])


def get_state():
    try:
        dump = json.loads(subprocess.run(["pw-dump"], capture_output=True, text=True).stdout)
    except Exception:
        return None

    card_id = None
    hp_index = None
    hp_available = "no"
    spk_index = None
    current_profile = ""
    default_sink_name = ""
    bt_sink_id = None
    spk_sink_id = None
    hp_sink_id = None

    for obj in dump:
        info = obj.get("info") or {}
        props = info.get("props") or {}

        if props.get("device.name") == CARD_NAME:
            card_id = obj.get("id")
            params = info.get("params") or {}
            for p in params.get("EnumProfile", []):
                if p.get("name") == PROFILE_HP:
                    hp_index = p.get("index")
                    hp_available = p.get("available")
                elif p.get("name") == PROFILE_SPK:
                    spk_index = p.get("index")
            profile_list = params.get("Profile") or [{}]
            current_profile = profile_list[0].get("name", "")

        if props.get("media.class") == "Audio/Sink":
            node_name = str(props.get("node.name", ""))
            if node_name.startswith("bluez_output"):
                bt_sink_id = obj.get("id")
            elif node_name.startswith("alsa_output"):
                if "Speaker" in node_name:
                    spk_sink_id = obj.get("id")
                elif "Headphone" in node_name:
                    hp_sink_id = obj.get("id")

        if obj.get("type") == "PipeWire:Interface:Metadata" and (obj.get("props") or {}).get("metadata.name") == "default":
            for m in obj.get("metadata", []):
                if m.get("key") == "default.audio.sink":
                    default_sink_name = (m.get("value") or {}).get("name", "")

    return {
        "card_id": card_id,
        "spk_index": spk_index,
        "hp_index": hp_index,
        "hp_plugged": hp_available == "yes",
        "bt_sink_id": bt_sink_id,
        "spk_sink_id": spk_sink_id,
        "hp_sink_id": hp_sink_id,
        "default_sink_name": default_sink_name,
        "current_profile": current_profile,
    }


def main():
    s = get_state()
    if not s or s["card_id"] is None:
        notify("Audio Output", "Không tìm thấy sound card.", "dialog-error")
        return

    card_id = s["card_id"]
    spk_index = s["spk_index"]
    hp_index = s["hp_index"]
    hp_plugged = s["hp_plugged"]
    bt_sink_id = s["bt_sink_id"]
    spk_sink_id = s["spk_sink_id"]
    hp_sink_id = s["hp_sink_id"]
    default_sink_name = s["default_sink_name"]

    # Xác định output hiện tại
    is_bt = "bluez_output" in default_sink_name
    is_speaker = ("Speaker" in default_sink_name or (s["current_profile"] == PROFILE_SPK and not is_bt))
    is_hp = ("Headphone" in default_sink_name or (s["current_profile"] == PROFILE_HP and not is_bt))

    # Nếu không có thiết bị tai nghe nào
    if not hp_plugged and bt_sink_id is None:
        if spk_index is not None:
            wpctl("set-profile", str(card_id), str(spk_index))
        if spk_sink_id is not None:
            wpctl("set-default", str(spk_sink_id))
        notify("Audio Output", "Không có tai nghe nào được kết nối!\nĐang sử dụng Loa Laptop.", "audio-speakers")
        return

    # Chuyển đổi trạng thái (Cycle: Speaker -> BT -> Wired HP -> Speaker)
    if is_speaker:
        if bt_sink_id is not None:
            wpctl("set-default", str(bt_sink_id))
            notify("Audio Output", "Đã chuyển sang Tai nghe Bluetooth", "audio-headphones")
        elif hp_plugged and hp_index is not None:
            wpctl("set-profile", str(card_id), str(hp_index))
            time.sleep(0.05)
            s2 = get_state()
            if s2 and s2["hp_sink_id"]:
                wpctl("set-default", str(s2["hp_sink_id"]))
            notify("Audio Output", "Đã chuyển sang Tai nghe dây", "audio-headphones")
    elif is_bt:
        if hp_plugged and hp_index is not None:
            wpctl("set-profile", str(card_id), str(hp_index))
            time.sleep(0.05)
            s2 = get_state()
            if s2 and s2["hp_sink_id"]:
                wpctl("set-default", str(s2["hp_sink_id"]))
            notify("Audio Output", "Đã chuyển sang Tai nghe dây", "audio-headphones")
        else:
            if spk_index is not None:
                wpctl("set-profile", str(card_id), str(spk_index))
            time.sleep(0.05)
            s2 = get_state()
            target_spk = s2["spk_sink_id"] if (s2 and s2["spk_sink_id"]) else spk_sink_id
            if target_spk is not None:
                wpctl("set-default", str(target_spk))
            notify("Audio Output", "Đã chuyển sang Loa Laptop", "audio-speakers")
    else:  # is_hp (tai nghe dây)
        if spk_index is not None:
            wpctl("set-profile", str(card_id), str(spk_index))
        time.sleep(0.05)
        s2 = get_state()
        target_spk = s2["spk_sink_id"] if (s2 and s2["spk_sink_id"]) else spk_sink_id
        if target_spk is not None:
            wpctl("set-default", str(target_spk))
        notify("Audio Output", "Đã chuyển sang Loa Laptop", "audio-speakers")


if __name__ == "__main__":
    main()
