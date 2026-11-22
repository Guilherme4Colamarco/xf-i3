#!/usr/bin/env bash
# salvar-xfce.sh: copies the current XFCE state into ~/rice/xfce/.
#
# XFCE rewrites its own files (xfconfd, panel, Thunar), so they are not
# symlinked like the rest of the rice: they are a copy. Run this after
# changing the panel, settings, or shortcuts through the XFCE GUI.
# Restore: bash ~/rice/instalar.sh --xfce
set -euo pipefail
R="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"
X="$R/xfce"; P="$HOME/.config/xfce4/xfconf/xfce-perchannel-xml"
# rice channels: panel, DPI/theme/cursor, 165 Hz monitor, session with i3,
# shortcuts, notifications, workspace names, Thunar, power, and screensaver
CANAIS=(xfce4-panel xsettings displays xfce4-session xfce4-keyboard-shortcuts xfce4-notifyd xfwm4 thunar xfce4-power-manager xfce4-screensaver)
rm -rf "$X"; mkdir -p "$X/xfconf" "$X/panel"
# give xfconfd time to flush anything still in memory
sleep 1
for c in "${CANAIS[@]}"; do [ -f "$P/$c.xml" ] && cp "$P/$c.xml" "$X/xfconf/"; done
cp -r "$HOME/.config/xfce4/panel/." "$X/panel/"
cp "$HOME/.config/xfce4/helpers.rc" "$X/helpers.rc"
cp "$HOME/.config/Thunar/uca.xml" "$X/uca.xml"
cp "$HOME/.config/mimeapps.list" "$X/mimeapps.list"
echo "XFCE snapshot saved to $X ($(find "$X" -type f | wc -l) files)"
