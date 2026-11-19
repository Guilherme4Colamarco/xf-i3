#!/usr/bin/env bash
# salvar-xfce.sh: copia o estado atual do XFCE para ~/rice/xfce/.
#
# O XFCE regrava os próprios arquivos (xfconfd, painel, Thunar), por isso eles
# não são links como o resto do rice: são uma cópia. Rode isto depois de mexer
# no painel, nas configurações ou nos atalhos pelas janelas do XFCE.
# Restaurar: bash ~/rice/instalar.sh --xfce
set -euo pipefail
R="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"
X="$R/xfce"; P="$HOME/.config/xfce4/xfconf/xfce-perchannel-xml"
# canais do rice: painel, DPI/tema/cursor, monitor 165 Hz, sessão com i3,
# atalhos, notificações, nomes de workspace e Thunar
CANAIS=(xfce4-panel xsettings displays xfce4-session xfce4-keyboard-shortcuts xfce4-notifyd xfwm4 thunar)
rm -rf "$X"; mkdir -p "$X/xfconf" "$X/panel"
# dá tempo do xfconfd gravar o que ainda está só na memória
sleep 1
for c in "${CANAIS[@]}"; do [ -f "$P/$c.xml" ] && cp "$P/$c.xml" "$X/xfconf/"; done
cp -r "$HOME/.config/xfce4/panel/." "$X/panel/"
cp "$HOME/.config/xfce4/helpers.rc" "$X/helpers.rc"
cp "$HOME/.config/Thunar/uca.xml" "$X/uca.xml"
cp "$HOME/.config/mimeapps.list" "$X/mimeapps.list"
echo "snapshot do XFCE salvo em $X ($(find "$X" -type f | wc -l) arquivos)"
