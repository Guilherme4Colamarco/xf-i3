# NixOS Port (Flake + Home Manager)

This directory packages the **XFCE + i3 (X11) + iris** rice as a Nix Flake with modules for **NixOS** and **Home Manager**, plus `iris-colors` and `skippy-xd` packages built from upstream.

## What the flake exposes

- `nixosModules.default` / `nixosModules.xfce-i3`: system base (X11, LightDM with `xfce+i3` session, XFCE without `xfwm4`/`xfdesktop`, `i3`, `xfce4-panel` + plugins, `picom`, `rofi`, `feh`, `adw-gtk3`, `bibata-cursors`, `papirus-icon-theme`, fonts, Thunar, etc.).
- `homeManagerModules.default` / `homeManagerModules.xfce-i3`: dotfiles (`i3`, `picom`, `rofi`, `iris` templates, `wireplumber`, optional `neovim`, and terminal stack with `kitty`, `fish`, `starship`, `yazi`, `cava`, `btop`, `fastfetch`), wrapped scripts with dependencies on `PATH`, autostart files, initial fallback in `~/.cache/iris`, and optional initial XFCE seed.
- `packages.<system>.{iris-colors,skippy-xd}` and `overlays.default`.
- `checks.<system>.{iris-colors,skippy-xd,nixos-eval,nixos-eval-brilho}`.

Declared systems: `x86_64-linux` and `aarch64-linux`.

## How to use

See the ready-to-copy file in [`example/flake.nix`](./example/flake.nix).

Summary of steps in your NixOS `flake.nix`:

1. Add this repository as an input (alongside `nixpkgs` `nixos-unstable` and `home-manager`).
2. Import `rice.nixosModules.default` in your system modules and enable `rice.xfce-i3.enable = true;`.
3. Import `rice.homeManagerModules.default` in your Home Manager user modules and enable `rice.xfce-i3.enable = true;`.
4. Run `sudo nixos-rebuild switch --flake .#your-host`.

## First login

- In LightDM, the configured default session is **`xfce+i3`** (starts XFCE services with `i3` as the window manager).
- Before the first wallpaper, Home Manager creates an initial neutral dark theme in `~/.cache/iris/` and `~/.local/share/themes/Iris-A/` (only if they don't already exist), so `i3`, `rofi`, `kitty`, `btop`, and `skippy-xd` open without errors.
- Press **`Super+Shift+b`** (or run `iris-wall --pick` / `iris-wall path/to/image`) to pick a wallpaper and generate the session color palette. By default, `iris-wall` searches for images in `~/Imagens/Wallpapers`, `~/Pictures/Wallpapers`, `~/Wallpapers`, and the directories listed in `wallpaperDirs`.

## Important notes

### Do not enable `gtk.enable = true` in Home Manager

`iris-wall` switches the GTK 3 theme live between the `Iris-A` and `Iris-B` slots in `~/.local/share/themes/`, and also writes `~/.config/gtk-3.0/settings.ini` and `~/.config/gtk-4.0/{gtk.css,settings.ini}`. Managing those files through Home Manager would create read-only symlinks that block live color switching.

### How `seedXfce` works

When `seedXfce = true` (default), Home Manager activation copies sanitized initial configs for the panel, notifications, shortcuts, `xsettings.xml`, Thunar's `uca.xml`, and `helpers.rc` **only if the target file does not exist yet**. After the first login you can change the panel, DPI, or shortcuts normally through XFCE's GUI.

### Brightness control via DDC/CI (`enableBrilho`)

When `enableBrilho = true`:

- The NixOS module enables `hardware.i2c.enable = true` and installs `ddcutil`.
- Add your user to the **`i2c`** group (`users.users.<name>.extraGroups = [ "i2c" ];`) to access `/dev/i2c-*` without `root`.
- If you have more than one monitor, you can pin the bus in `brilhoBus` (in Home Manager); with `brilhoBus = null` (default), `brilho` uses `ddcutil` auto-detection.

## Module options

### NixOS Module (`rice.xfce-i3.*`)

| Option | Type | Default | Description |
|---|---|---|---|
| `enable` | `bool` | `false` | Enables the XFCE + i3 environment and base packages. |
| `enableDisplayManager` | `bool` | `true` | Enables LightDM (GTK greeter) and default `xfce+i3` session. |
| `enableBrilho` | `bool` | `false` | Enables `hardware.i2c` and installs `ddcutil`. |
| `installFonts` | `bool` | `true` | Installs `noto-fonts`, `nerd-fonts.jetbrains-mono`, and `nerd-fonts.space-mono`. |
| `installExtraApps` | `bool` | `true` | Installs extra apps (`mpv` and `file-roller`). |
| `enableTerminalStack` | `bool` | `true` | Enables `programs.fish` system-wide. |

### Home Manager Module (`rice.xfce-i3.*`)

| Option | Type | Default | Description |
|---|---|---|---|
| `enable` | `bool` | `false` | Enables user dotfiles, scripts, and seeds. |
| `enableTerminalStack` | `bool` | `true` | Installs `kitty`, `fish`, `starship`, `zoxide`, `fzf`, `eza`, `fd`, `btop`, `fastfetch`, `yazi`, `cava`, and `TERMINAL=kitty`. |
| `enableNeovim` | `bool` | `true` | Installs `neovim` with LazyVim config (`lazy-lock.json` seeded as writable). |
| `enableBrilho` | `bool` | `false` | Installs the `brilho` script and adds the `genmon` indicator to the panel seed. |
| `brilhoBus` | `nullOr int` | `null` | Monitor I2C bus (`null` uses auto-detection). |
| `dpi` | `nullOr int` | `null` | Initial DPI written to `xsettings.xml` (e.g. `125`). |
| `cursorTheme` | `str` | `"Bibata-Modern-Ice"` | Initial cursor theme in the XFCE seed. |
| `cursorSize` | `int` | `24` | Initial cursor size in the XFCE seed. |
| `iconTheme` | `str` | `"Papirus"` | Initial icon theme in the XFCE seed. |
| `kitty.fontFamily` | `str` | `"JetBrainsMono Nerd Font"` | Font in `~/.config/kitty/current-font.conf`. |
| `kitty.fontSize` | `int \| float` | `12` | Font size in `~/.config/kitty/current-font.conf`. |
| `fastfetch.logo` | `str` | `"NixOS_small"` | Built-in `fastfetch` logo. |
| `wallpaperDirs` | `listOf str` | `[]` | Extra directories for the `iris-wall` picker. |
| `initialWallpaper` | `nullOr path` | `null` | Wallpaper written to `~/.cache/iris/wallpaper` if no saved state exists. |
| `seedXfce` | `bool` | `true` | Seeds initial XFCE/Thunar configs only if missing. |
| `webBrowser` | `nullOr str` | `null` | Initial default browser written to `~/.config/xfce4/helpers.rc`. |
| `extraI3Config` | `lines` | `""` | Extra lines appended to the end of `~/.config/i3/config`. |

## Check and build

On a machine with Nix + flakes enabled and `nix-daemon` running:

```sh
nix flake check
nix build .#iris-colors .#skippy-xd
```
