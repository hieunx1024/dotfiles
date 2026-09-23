#!/usr/bin/env python3
"""Chuyển đổi Loa laptop / Tai nghe dây / Tai nghe Bluetooth (Super+Shift+A).
Dùng pw-dump + wpctl (PipeWire thuần) thay cho pactl (không có trên máy này)."""

import json
import subprocess

CARD_NAME = "alsa_card.pci-0000_07_00.6"
PROFILE_HP = "HiFi (Headphones, Mic1, Mic2)"
PROFILE_SPK = "HiFi (Mic1, Mic2, Speaker)"


def notify(title, body, icon):
    subprocess.run(["notify-send", title, body, "-i", icon])


def wpctl(*args):
    subprocess.run(["wpctl", *args])


def main():
    dump = json.loads(subprocess.run(["pw-dump"], capture_output=True, text=True).stdout)

    card_id = None
    hp_index = None
    hp_available = "no"
    spk_index = None
    current_profile = ""
    default_sink_name = ""
    bt_sink_id = None

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
            bt_sink_id = obj["id"]

        if obj.get("type") == "PipeWire:Interface:Metadata" and (obj.get("props") or {}).get("metadata.name") == "default":
            for m in obj.get("metadata", []):
                if m.get("key") == "default.audio.sink":
                    default_sink_name = (m.get("value") or {}).get("name", "")

    if card_id is None:
        notify("Audio Output", "Không tìm thấy sound card.", "dialog-error")
        return

    hp_plugged = hp_available == "yes"
    bt_available = bt_sink_id is not None

    if not hp_plugged and not bt_available:
        wpctl("set-profile", str(card_id), str(spk_index))
        notify("Audio Output", "Không có tai nghe nào được kết nối!\nĐang sử dụng Loa Laptop.", "audio-speakers")
        return

    is_speaker = current_profile == PROFILE_SPK and "bluez" not in default_sink_name

    if is_speaker:
        if bt_available:
            wpctl("set-default", str(bt_sink_id))
            notify("Audio Output", "Đã chuyển sang Tai nghe Bluetooth", "audio-headphones")
        else:
            wpctl("set-profile", str(card_id), str(hp_index))
            notify("Audio Output", "Đã chuyển sang Tai nghe dây", "audio-headphones")
    else:
        wpctl("set-profile", str(card_id), str(spk_index))
        notify("Audio Output", "Đã chuyển sang Loa Laptop", "audio-speakers")


if __name__ == "__main__":
    main()
