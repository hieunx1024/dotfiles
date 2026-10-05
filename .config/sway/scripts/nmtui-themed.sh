#!/bin/bash
# =============================================================================
# NMTUI THEMED - Đồng bộ giao diện Dark / Graphite với hệ thống
# Sử dụng NEWT_COLORS để đổi màu toàn bộ libnewt (khử hoàn toàn nền xanh cổ điển)
# =============================================================================

export NEWT_COLORS='
root=lightgray,black
border=lightgray,black
window=lightgray,black
shadow=black,black
title=white,black
button=black,lightgray
actbutton=lightgray,black
checkbox=lightgray,black
actcheckbox=black,lightgray
entry=white,black
label=lightgray,black
listbox=lightgray,black
actlistbox=black,lightgray
textbox=lightgray,black
acttextbox=black,lightgray
helpline=gray,black
roottext=lightgray,black
emptyscale=gray,black
fullscale=lightgray,black
disentry=gray,black
compactbutton=black,lightgray
actsellistbox=black,lightgray
'

exec nmtui "$@"
