# rice: XFCE + i3

CachyOS with **i3** handling window management and **XFCE** handling the rest: panel, tray, notifications, volume, power, screen lock, settings, and Thunar.
**iris** extracts colors from the wallpaper and themes everything.
Monitor DP-0 at 1920x1080 / 165 Hz, 1.3x scaling via DPI (125), Bibata 32 cursor.

Set up on 2026-11-18/19, after removing Ryoku and pleamar-wm.

## How this folder works

The actual files live here. In the usual locations (`~/.config/...`, `~/.local/bin/...`) there are **symlinks** pointing here. Editing `~/.config/i3/config` or `~/rice/config/i3/config` is the same thing.

XFCE configs are the exception: XFCE itself rewrites those files, so `xfce/` is a **copy**. After changing the panel, shortcuts, or settings through XFCE's GUI, run `bash ~/rice/salvar-xfce.sh`.

| Folder / file | What it does |
|---|---|
| `config/i3/config` | i3: vim keybindings, floating rules, dynamic workspaces, overview |
| `config/picom/picom.conf`, `picom-xfwm4.conf` | compositor: animations, blur, shadows, and rounded corners (separate rules for i3 and xfwm4) |
| `config/xfwm4/sxhkdrc` | app shortcuts used only in the `xfwm4` session (without touching i3) |
| `config/iris/templates/` | colors generated from the wallpaper: GTK 3/4, panel, notifications, i3, rofi, fish, btop, overview |
| `config/rofi/`, `config/kitty/`, `config/fish/`, `config/starship.toml`, `config/btop/`, `config/fastfetch/`, `config/nvim/`, `config/yazi/`, `config/cava/`, `config/qt6ct/` | daily-use apps |
| `config/environment.d/`, `config/wireplumber/`, `config/nix/` | session/locale variables, Bluetooth codecs (WirePlumber), and `nix.conf` |
| `config/gtk-3.0/gtk.css` | intentionally empty (any color here would lock the iris theme) |
| `config/autostart/` | what XFCE launches at login: picom, wallpaper, overview, dynamic workspaces, pager names |
| `bin/iris-wall` | changes the wallpaper and repaints everything live |
| `bin/i3-ws`, `bin/i3-dynamic-ws` | GNOME/niri-style dynamic workspaces (always 1..9 in sequence) |
| `bin/brilho` | real monitor brightness via DDC/CI, with OSD and panel indicator |
| `bin/i3-desktop-mode` | toggles the current workspace between tiling and all-floating |
| `bin/i3-xfce-wsnames` | makes the panel pager display i3 workspace names |
| `bin/rice-wm`, `rice-session`, `rice-wm-switch`, `rice-picom` | switch between `i3` and `xfwm4` in the XFCE session (via LightDM or terminal) |
| `applications/` | "Wallpaper" in Settings opens the iris-wall picker |
| `xfce/` | copy of XFCE configs: panel, DPI/theme, monitor, i3 session, shortcuts, notifications, Thunar, default apps |
| `pacotes.txt`, `pacotes-aur.txt` | packages required by the rice |
| `instalar.sh`, `salvar-xfce.sh` | install the rice in place / update the XFCE copy |
| `flake.nix`, `nix/` | NixOS port (flake with NixOS + Home Manager modules, packages, and example) |

## Keybindings (Super = Windows key)

| Key | Action |
|---|---|
| `Super+h j k l` | focus (arrow keys also work) |
| `Super+Shift+h j k l` | move window |
| `Super+Ctrl+h j k l` | resize; `Super+r` enters resize mode (hjkl, Shift = larger step) |
| `Super+v` / `Super+s` | next window to the right (`:vsplit`) / below (`:split`) |
| `Super+Shift+v` | toggle split direction |
| `Super+t` / `Super+g` | tabbed / stacked |
| `Super+f` | fullscreen |
| `Super+x` | toggle floating / tiling |
| `Super+space` | toggle focus between tiled and floating |
| `Super+a` / `Super+Shift+a` | focus parent / child |
| `Super+q` | close |
| `Super+Shift+w` / `Super+w` | "minimize" (scratchpad) / show |
| `Super+Alt+h j k l` (or arrows) | previous (h/k) / next (j/l) workspace; same as `Super+,` / `Super+.` |
| `Super+Shift+t` | desktop mode: entire workspace floats or returns to tiling |
| `Super+1..9` | workspace N (if it doesn't exist, opens a new one at the end) |
| `Super+Shift+1..9` | send window to workspace N |
| `Super+0` | "free" workspace 10, where everything floats |
| `Super+n` / `Super+Shift+n` | new empty workspace / move window to a new one |
| `Super+.` / `Super+,` | next / previous (on the last one, `Super+.` creates a new one) |
| `Super+Shift+.` / `Super+Shift+,` | move window to next / previous |
| `Super+Tab` / `Super+Shift+Tab` | workspaces overview / current workspace windows (hjkl, Enter, Esc) |
| `Super+Return` | terminal (kitty) |
| `Super+e` | Thunar |
| `Super+d` | Application Finder |
| `Super+Shift+d` | rofi |
| `Alt+Tab` | window list |
| `Ctrl+Esc` / `Alt+F1` | applications menu |
| `Super+Shift+b` | pick wallpaper (theme updates along with it) |
| `Super+Shift+v` | clipboard history (Clipman) |
| `Super+p` | displays |
| `Super+Ctrl+-` / `Super+Ctrl+=` | monitor brightness −10% / +10% (with Shift: 2% step); clicking ☀ on the panel picks a level |
| `Super+Escape` | lock screen |
| `Super+Shift+e` | log out / shut down |
| `Super+Shift+c` / `Super+Shift+r` | reload / restart i3 |
| `Print`, `Shift+Print`, `Alt+Print` | screenshot of screen / area / window |

## Daily usage

- **Change wallpaper:** `Super+Shift+b`, right-click an image in Thunar ("Set as wallpaper"), or `iris-wall path/to/image`. Wallpapers live in `~/Imagens/Wallpapers`. Use `-d`/`-l` to force dark/light theme.
- **Change a color or style:** edit the template in `config/iris/templates/` and run `iris-wall --restore`. Do not edit the generated files in `~/.cache/iris`.
- **Animations, blur, and transparency:** `config/picom/picom.conf`, then `pkill -USR1 -x picom`. "Glass" apps are in the rule with `opacity = 0.92`; remove an app from the list or raise the value to make it more opaque.
- **GTK 4 apps** pick up new colors when reopened; everything else updates immediately.

## Reinstall from scratch

```sh
bash ~/rice/instalar.sh --pacotes --xfce
```

After that, log out and log back in (choose "Xfce Session" in LightDM) and run `iris-wall --pick` to choose a wallpaper.

## NixOS

There is also a full **NixOS** port via Flake + Home Manager (`nixosModules.default` and `homeManagerModules.default`), packaging `iris-colors` and `skippy-xd` and keeping this repository's dotfiles as the single source of truth.

See instructions, module options, and a ready-to-use example in [`nix/README.md`](nix/README.md) and [`nix/example/flake.nix`](nix/example/flake.nix).

## Alternative session: XFCE + xfwm4

In addition to **XFCE + i3** (default), the rice also supports **XFCE + xfwm4** (traditional floating windows) without conflicting with i3:

- **Via LightDM (login):** choose **Xfce + xfwm4** on the login screen (`xsessions/xfce-xfwm4.desktop`).
- **Via terminal:** `rice-wm-switch xfwm4` (or `rice-wm-switch i3` / `rice-wm-switch status`) sets which WM the default **Xfce Session** launches on the next login.
- Under `xfwm4`: `picom` uses `config/picom/picom-xfwm4.conf`, `sxhkd` loads `config/xfwm4/sxhkdrc` with the same app shortcuts (`Super+Return`, `Super+e`, `Super+d`, `Super+Shift+b`, `Super+Tab`, brightness, etc.), `xfdesktop` manages the desktop, and `iris-wall` updates both the wallpaper and a flat theme for the `xfwm4` titlebar.

## Backups

All backups were placed in `~/Documentos/Backups/`:

- `2026-11-18 xfce antes do i3/`: XFCE and GTK configs from before i3.
- `2026-11-18 remoção ryoku-pleamar/`: system backups from removing Ryoku, Ryoku data, and `pleamar-arquivo/`. The latter has your Marea and Vitreus commits that never went to GitHub; see `LEIA-ME.txt` inside it.
- `dotfiles/`: old `.bashrc`.
