# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A personal desktop "rice" (dotfiles) for CachyOS/Arch: **i3** manages windows, **XFCE** provides everything else (panel, tray, notifications, power, lock, settings, Thunar), and **iris** (`iris-colors`, AUR) generates a color palette from the wallpaper that themes the whole session. There is no build system or test suite; the code is bash scripts plus config files. Comments, UI strings, and docs are in English; keep that convention. `README.md` is the user-facing README (keybinding table, daily usage) — keep it in sync when changing shortcuts or adding files.

This directory is not a git repository.

## Commands

- Install/relink: `bash ~/rice/instalar.sh` (flags: `--pacotes` installs `pacotes.txt` via pacman and `pacotes-aur.txt` via yay; `--xfce` restores the `xfce/` snapshot). Idempotent. If the session is running it also reloads i3, re-runs `iris-wall --restore` and signals picom.
- Snapshot XFCE state back into the repo: `bash ~/rice/salvar-xfce.sh`
- Apply a wallpaper and repaint everything: `iris-wall IMAGE` (`--pick` rofi picker, `--restore` reapply last, `-d`/`-l` force dark/light)
- Reload after edits: `i3-msg reload` (restart: `i3-msg restart`), `pkill -USR1 -x picom`, `pkill -USR1 -x kitty`
- Validate scripts: `bash -n bin/<script>` (and `shellcheck` if installed). Validate i3 config: `i3 -C -c config/i3/config`.

## Architecture

**Symlinks vs. copies.** The real files live in `~/rice`; `~/.config/...` and `~/.local/bin/...` hold symlinks to them (edit either path). The table of source→destination pairs is the `LINKS` array in `instalar.sh` — **any new config/script/desktop file must be added there** or it won't be linked. An existing real file at a destination is moved to `~/rice/.antes/` before linking. The exception is `xfce/`: XFCE rewrites its own files, so `xfce/` is a *copy* (xfconf channel XMLs, panel launchers, `helpers.rc`, Thunar `uca.xml`, `mimeapps.list`). Editing `xfce/` does not affect the live session; change things via XFCE and run `salvar-xfce.sh`, or edit the copy and apply with `instalar.sh --xfce`. The channel list lives in `CANAIS` in `salvar-xfce.sh`.

**iris color pipeline** (`bin/iris-wall`, the central script). Templates in `config/iris/templates/` (symlinked to `~/.config/iris/templates`) use `{color}` / `{color.strip}` placeholders; `iris` renders them into `~/.cache/iris/` (colors.json, `i3-colors.conf`, `colors.rasi`, `colors-kitty.conf`, `colors.fish`, `btop.theme`, `gtk3-colors.css`, `gtk4.css`, `notify.css`, `skippy-xd.rc`). Consumers `include`/`@import` from that cache (i3 config, rofi, kitty), so **never edit `~/.cache/iris` files — edit the template and run `iris-wall --restore`**. Note i3 `include`s the cache file, so i3 won't load properly before iris has run once. `iris-wall` also: sets the wallpaper with `feh` (xfdesktop doesn't run under i3), publishes GTK3 theme live via alternating `Iris-A`/`Iris-B` slots in `~/.local/share/themes` (GTK3 only re-reads CSS when the theme *name* changes), writes GTK4/libadwaita CSS and `settings.ini`, sets fish universal color vars (`set -U`), and reloads i3/kitty/skippy-xd. `config/gtk-3.0/gtk.css` is intentionally empty — any color there would lock the iris theme.

**i3 inside an XFCE session.** The XFCE session launches i3 as window manager (session config in `xfce/xfconf/xfce4-session.xml`); there is no i3bar — the XFCE panel is the only bar. Autostart items in `config/autostart/*.desktop` (picom, iris-wall restore, skippy-xd overview daemon, dynamic workspaces, workspace-name sync) are `OnlyShowIn=XFCE`. Terminal and file manager are launched via `exo-open` (XFCE "preferred apps"), not hardcoded.

**Dynamic workspaces** span three pieces that must stay consistent: `bin/i3-dynamic-ws` (daemon: keeps numeric workspaces 1..9 contiguous by renaming on `empty/init/move` events; names that aren't plain numbers, like `"10:livre"`, are ignored), `bin/i3-ws` (keybinding actions new/next/prev/move-*; `MAX=9`), and the `$ws1..$ws10` / `$mod+...` bindings in `config/i3/config`. Workspace 10 `"10:livre"` is the all-floating "desktop mode" workspace (`for_window [workspace="^10"]`); `bin/i3-desktop-mode` toggles the same behavior on any workspace. `bin/i3-xfce-wsnames` exists because `xfsettingsd` overwrites `_NET_DESKTOP_NAMES` from xfconf `xfwm4:/general/workspace_names`; it copies i3 names into that xfconf key so the panel pager shows them.

**Other scripts.** `bin/brilho` controls monitor brightness over DDC/CI (`ddcutil`, bus 3 by default, override with `BRILHO_BUS`); DDC is slow, so it caches in `$XDG_RUNTIME_DIR/brilho` and a single flock'd background applier always converges to the latest target. It also feeds a panel genmon plugin via `brilho panel`. `applications/xfce-backdrop-settings.desktop` overrides the XFCE "Desktop" settings entry so it opens `iris-wall --pick`.

## Gotchas

- Machine-specific values are hardcoded: `/home/geko/...` in the `.desktop` files, DP-0 1920x1080@165 Hz and DPI 125 (scale 1.3) in `xfce/xfconf/{displays,xsettings}.xml`, DDC bus 3 in `brilho`. Keep these in mind before generalizing.
- i3 font size relies on `Xft.dpi` published by `xfsettingsd`, not on i3 settings.
- picom: the "glass" opacity (0.92 + blur) for GTK apps and the floating-only shadows/corners are rules in `config/picom/picom.conf`; reload with `pkill -USR1 -x picom`.
- `config/kitty/kitty.conf` includes `current-font.conf` (separate file so font changes can reload via SIGUSR1) and an optional `user.conf` that is never shipped.
- `pacotes-aur.txt` notes that the Bibata cursor currently comes from a `[ryoku]` repo package; on a fresh machine use `bibata-cursor-theme-bin`.
