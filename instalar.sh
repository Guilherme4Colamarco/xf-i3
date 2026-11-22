#!/usr/bin/env bash
# instalar.sh: puts the rice in place.
#
#   bash ~/rice/instalar.sh             creates symlinks from ~/.config, ~/.local/bin, etc. to here
#   bash ~/rice/instalar.sh --xfce      also restores the XFCE snapshot (panel, DPI, session
#                                       with i3, shortcuts, notifications, Thunar, default apps)
#   bash ~/rice/instalar.sh --packages  installs the rice packages (pacman + AUR via yay)
#                                       (--pacotes is also accepted as an alias)
#
# Safe to re-run: existing correct links stay as they are; any real file
# in the way is moved to ~/rice/.antes/ before being replaced with a link.
set -euo pipefail
R="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"

# source (in rice)                             destination (in home)
LINKS=(
  "config/i3/config                           .config/i3/config"
  "config/picom/picom.conf                    .config/picom/picom.conf"
  "config/picom/picom-xfwm4.conf              .config/picom/picom-xfwm4.conf"
  "config/xfwm4/sxhkdrc                       .config/xfwm4/sxhkdrc"
  "config/rofi/config.rasi                    .config/rofi/config.rasi"
  "config/kitty/kitty.conf                    .config/kitty/kitty.conf"
  "config/kitty/current-font.conf             .config/kitty/current-font.conf"
  "config/fish/config.fish                    .config/fish/config.fish"
  "config/btop/btop.conf                      .config/btop/btop.conf"
  "config/fastfetch/config.jsonc              .config/fastfetch/config.jsonc"
  "config/starship.toml                        .config/starship.toml"
  "config/nvim                                 .config/nvim"
  "config/yazi                                 .config/yazi"
  "config/cava/config                          .config/cava/config"
  "config/qt6ct/qt6ct.conf                     .config/qt6ct/qt6ct.conf"
  "config/qt6ct/colors/ryoku.conf              .config/qt6ct/colors/ryoku.conf"
  "config/environment.d/50-session.conf        .config/environment.d/50-session.conf"
  "config/environment.d/locale.conf            .config/environment.d/locale.conf"
  "config/wireplumber/wireplumber.conf.d/51-ryoku-bluetooth.conf .config/wireplumber/wireplumber.conf.d/51-ryoku-bluetooth.conf"
  "config/nix/nix.conf                         .config/nix/nix.conf"
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
  "bin/rice-session                           .local/bin/rice-session"
  "bin/rice-wm                                .local/bin/rice-wm"
  "bin/rice-wm-switch                         .local/bin/rice-wm-switch"
  "bin/rice-picom                             .local/bin/rice-picom"
  "applications/xfce-backdrop-settings.desktop .local/share/applications/xfce-backdrop-settings.desktop"
)

link() {
    local src="$R/$1" dst="$HOME/$2"
    [ -e "$src" ] || { echo "  !! missing in rice: $1"; return; }
    mkdir -p "$(dirname "$dst")"
    if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then return; fi
    if [ -e "$dst" ] || [ -L "$dst" ]; then
        mkdir -p "$R/.antes/$(dirname "$2")"
        mv "$dst" "$R/.antes/$2.$(date +%Y%m%d-%H%M%S)"
        echo "  backed up to .antes/: ~/$2"
    fi
    ln -s "$src" "$dst"
    echo "  linked: ~/$2"
}

xfce_restore() {
    local X="$R/xfce"
    [ -d "$X/xfconf" ] || { echo "  !! no snapshot in $X (run salvar-xfce.sh on a configured machine)"; return; }
    echo "==> linking XFCE configs via symlink"
    link "xfce/xfconf"       ".config/xfce4/xfconf/xfce-perchannel-xml"
    link "xfce/panel"        ".config/xfce4/panel"
    link "xfce/helpers.rc"   ".config/xfce4/helpers.rc"
    link "xfce/uca.xml"      ".config/Thunar/uca.xml"
    link "xfce/mimeapps.list" ".config/mimeapps.list"
    # xfconfd reloads XMLs the next time a value is requested
    pkill -x xfconfd 2>/dev/null || true
    pgrep -x xfce4-panel >/dev/null && xfce4-panel -r || true
    echo "  done. Log out and back in for the session to start with i3."
}

pacotes() {
    echo "==> repository packages"
    sudo pacman -S --needed $(grep -vE '^\s*(#|$)' "$R/pacotes.txt")
    echo "==> AUR packages"
    yay -S --needed $(grep -vE '^\s*(#|$)' "$R/pacotes-aur.txt")
    if [ -f "$R/xsessions/xfce-xfwm4.desktop" ]; then
        echo "==> LightDM session (Xfce + xfwm4)"
        sudo install -m 644 "$R/xsessions/xfce-xfwm4.desktop" /usr/share/xsessions/xfce-xfwm4.desktop
    fi
}

for a in "$@"; do [[ "$a" = --pacotes || "$a" = --packages ]] && pacotes; done

echo "==> links"
for l in "${LINKS[@]}"; do read -r src dst <<<"$l"; link "$src" "$dst"; done

for a in "$@"; do [ "$a" = --xfce ] && xfce_restore; done

# apply immediately if the session is already running
if pgrep -x i3 >/dev/null; then
    i3-msg -q reload && echo "==> i3 reloaded"
    "$HOME/.local/bin/iris-wall" --restore >/dev/null 2>&1 && echo "==> iris colors reapplied" || true
    pkill -USR1 -x picom 2>/dev/null || true
fi
echo "Done."
