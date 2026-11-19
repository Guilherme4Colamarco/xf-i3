#!/usr/bin/env bash
# instalar.sh: coloca o rice no lugar.
#
#   bash ~/rice/instalar.sh            cria os links de ~/.config, ~/.local/bin etc. para cá
#   bash ~/rice/instalar.sh --xfce     também restaura o snapshot do XFCE (painel, DPI, sessão
#                                      com i3, atalhos, notificações, Thunar, apps padrão)
#   bash ~/rice/instalar.sh --pacotes  instala os pacotes do rice (pacman + AUR via yay)
#
# Seguro de rodar de novo: links certos ficam como estão; um arquivo de verdade
# que estiver no caminho vai para ~/rice/.antes/ antes de virar link.
set -euo pipefail
R="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"

# origem (no rice)                            destino (na home)
LINKS=(
  "config/i3/config                           .config/i3/config"
  "config/picom/picom.conf                    .config/picom/picom.conf"
  "config/rofi/config.rasi                    .config/rofi/config.rasi"
  "config/kitty/kitty.conf                    .config/kitty/kitty.conf"
  "config/kitty/current-font.conf             .config/kitty/current-font.conf"
  "config/fish/config.fish                    .config/fish/config.fish"
  "config/btop/btop.conf                      .config/btop/btop.conf"
  "config/fastfetch/config.jsonc              .config/fastfetch/config.jsonc"
  "config/gtk-3.0/gtk.css                     .config/gtk-3.0/gtk.css"
  "config/iris/templates                      .config/iris/templates"
  "config/xdg-terminals.list                  .config/xdg-terminals.list"
  "config/autostart/picom.desktop             .config/autostart/picom.desktop"
  "config/autostart/iris-wall-restore.desktop .config/autostart/iris-wall-restore.desktop"
  "config/autostart/i3-xfce-wsnames.desktop   .config/autostart/i3-xfce-wsnames.desktop"
  "config/autostart/i3-dynamic-ws.desktop     .config/autostart/i3-dynamic-ws.desktop"
  "config/autostart/skippy-xd.desktop         .config/autostart/skippy-xd.desktop"
  "xprofile                                   .xprofile"
  "bin/iris-wall                              .local/bin/iris-wall"
  "bin/i3-ws                                  .local/bin/i3-ws"
  "bin/brilho                                 .local/bin/brilho"
  "bin/i3-dynamic-ws                          .local/bin/i3-dynamic-ws"
  "bin/i3-desktop-mode                        .local/bin/i3-desktop-mode"
  "bin/i3-xfce-wsnames                        .local/bin/i3-xfce-wsnames"
  "applications/xfce-backdrop-settings.desktop .local/share/applications/xfce-backdrop-settings.desktop"
)

link() {
    local src="$R/$1" dst="$HOME/$2"
    [ -e "$src" ] || { echo "  !! falta no rice: $1"; return; }
    mkdir -p "$(dirname "$dst")"
    if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then return; fi
    if [ -e "$dst" ] || [ -L "$dst" ]; then
        mkdir -p "$R/.antes/$(dirname "$2")"
        mv "$dst" "$R/.antes/$2.$(date +%Y%m%d-%H%M%S)"
        echo "  guardado em .antes/: ~/$2"
    fi
    ln -s "$src" "$dst"
    echo "  ligado: ~/$2"
}

xfce_restore() {
    local X="$R/xfce" P="$HOME/.config/xfce4/xfconf/xfce-perchannel-xml"
    [ -d "$X/xfconf" ] || { echo "  !! sem snapshot em $X (rode salvar-xfce.sh numa máquina já configurada)"; return; }
    echo "==> restaurando o snapshot do XFCE"
    mkdir -p "$P" "$HOME/.config/xfce4/panel" "$HOME/.config/Thunar"
    cp -v "$X"/xfconf/*.xml "$P/"
    cp -rv "$X"/panel/. "$HOME/.config/xfce4/panel/"
    cp -v "$X/helpers.rc" "$HOME/.config/xfce4/helpers.rc"
    cp -v "$X/uca.xml" "$HOME/.config/Thunar/uca.xml"
    cp -v "$X/mimeapps.list" "$HOME/.config/mimeapps.list"
    # o xfconfd relê os XML na próxima vez que alguém pedir um valor
    pkill -x xfconfd 2>/dev/null || true
    pgrep -x xfce4-panel >/dev/null && xfce4-panel -r || true
    echo "  feito. Faça logout/login para a sessão subir com o i3."
}

pacotes() {
    echo "==> pacotes do repositório"
    sudo pacman -S --needed $(grep -vE '^\s*(#|$)' "$R/pacotes.txt")
    echo "==> pacotes do AUR"
    yay -S --needed $(grep -vE '^\s*(#|$)' "$R/pacotes-aur.txt")
}

for a in "$@"; do [ "$a" = --pacotes ] && pacotes; done

echo "==> links"
for l in "${LINKS[@]}"; do read -r src dst <<<"$l"; link "$src" "$dst"; done

for a in "$@"; do [ "$a" = --xfce ] && xfce_restore; done

# aplica na hora se a sessão já estiver rodando
if pgrep -x i3 >/dev/null; then
    i3-msg -q reload && echo "==> i3 recarregado"
    "$HOME/.local/bin/iris-wall" --restore >/dev/null 2>&1 && echo "==> cores do iris reaplicadas" || true
    pkill -USR1 -x picom 2>/dev/null || true
fi
echo "Pronto."
