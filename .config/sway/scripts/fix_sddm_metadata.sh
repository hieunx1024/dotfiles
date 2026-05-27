#!/bin/bash
# Script to fix SDDM theme metadata group header and update QML layout

METADATA_TARGET="/usr/share/sddm/themes/gruvbox-minimal/metadata.desktop"
QML_SOURCE="/home/hieunx/.config/sway/scripts/Main.qml"
QML_TARGET="/usr/share/sddm/themes/gruvbox-minimal/Main.qml"

if [ ! -f "$METADATA_TARGET" ]; then
    echo "Error: Theme metadata file not found at $METADATA_TARGET"
    exit 1
fi

echo "Updating SDDM theme metadata group header..."
sudo sed -i 's/\[Type=sddm-theme\]/\[SddmGreeterTheme\]/' "$METADATA_TARGET"

if [ $? -eq 0 ]; then
    echo "Success! The group header has been updated to [SddmGreeterTheme]."
else
    echo "Failed to update the metadata file."
    exit 1
fi

if [ -f "$QML_SOURCE" ]; then
    echo "Copying updated Main.qml layout to $QML_TARGET..."
    sudo cp "$QML_SOURCE" "$QML_TARGET"
    if [ $? -eq 0 ]; then
        echo "Success! The new layout has been installed."
    else
        echo "Failed to copy Main.qml."
        exit 1
    fi
else
    echo "Error: Updated Main.qml source not found at $QML_SOURCE"
    exit 1
fi

echo "All tasks completed successfully! You can reboot or restart SDDM to apply."
