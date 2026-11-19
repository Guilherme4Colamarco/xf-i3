# Módulo Home Manager: configura dotfiles, scripts, autostart e seed inicial do rice.
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.rice.xfce-i3;
  irisColors = pkgs.iris-colors or (pkgs.callPackage ../pkgs/iris-colors.nix { });
  skippyXd = pkgs.skippy-xd or (pkgs.callPackage ../pkgs/skippy-xd.nix { });

  riceScripts = import ../lib/scripts.nix {
    inherit pkgs lib;
    iris-colors = irisColors;
    skippy-xd = skippyXd;
    enableBrilho = cfg.enableBrilho;
    brilhoBus = cfg.brilhoBus;
    wallpaperDirs = cfg.wallpaperDirs;
  };

  xfceSeed = import ../lib/xfce-seed.nix {
    inherit pkgs lib riceScripts;
    homeDirectory = config.home.homeDirectory;
    enableTerminalStack = cfg.enableTerminalStack;
    enableBrilho = cfg.enableBrilho;
    dpi = cfg.dpi;
    cursorTheme = cfg.cursorTheme;
    cursorSize = cfg.cursorSize;
    iconTheme = cfg.iconTheme;
    webBrowser = cfg.webBrowser;
  };

  # Paleta escura neutra inicial usada antes do primeiro `iris-wall`
  fallbackPalette = {
    bg = "#1e1f22";
    surface = "#2b2d31";
    fg = "#e6e2dc";
    dim = "#7a7f87";
    accent = "#89b4fa";
    red = "#f38ba8";
    green = "#a6e3a1";
    yellow = "#f9e2af";
    syntax_keyword = "#cba6f7";
    syntax_string = "#a6e3a1";
    syntax_func = "#89b4fa";
    syntax_type = "#94e2d5";
    syntax_const = "#fab387";
    syntax_param = "#74c7ec";
    syntax_operator = "#89dceb";
    syntax_comment = "#6c7086";
  };

  stripHash = hex: lib.removePrefix "#" hex;

  renderIrisTemplate =
    path:
    let
      keys = builtins.attrNames fallbackPalette;
      placeholders = (map (k: "{${k}}") keys) ++ (map (k: "{${k}.strip}") keys);
      values =
        (map (k: fallbackPalette.${k}) keys) ++ (map (k: stripHash fallbackPalette.${k}) keys);
    in
    builtins.replaceStrings placeholders values (builtins.readFile path);

  fallbackColorsJson = builtins.toJSON (
    fallbackPalette
    // {
      dark = true;
      tone_l = 0.2;
    }
  );

  fallbackKittyColors = ''
    background ${fallbackPalette.bg}
    foreground ${fallbackPalette.fg}
    cursor ${fallbackPalette.fg}

    selection_background ${fallbackPalette.accent}
    selection_foreground ${fallbackPalette.bg}

    color0  ${fallbackPalette.bg}
    color1  ${fallbackPalette.red}
    color2  ${fallbackPalette.green}
    color3  ${fallbackPalette.yellow}
    color4  ${fallbackPalette.accent}
    color5  ${fallbackPalette.syntax_keyword}
    color6  ${fallbackPalette.syntax_func}
    color7  ${fallbackPalette.dim}
    color8  ${fallbackPalette.surface}
    color9  ${fallbackPalette.red}
    color10 ${fallbackPalette.green}
    color11 ${fallbackPalette.yellow}
    color12 ${fallbackPalette.accent}
    color13 ${fallbackPalette.syntax_keyword}
    color14 ${fallbackPalette.syntax_func}
    color15 ${fallbackPalette.fg}
  '';

  fallbackIrisFiles = {
    "colors.json" = pkgs.writeText "iris-colors.json" fallbackColorsJson;
    "colors-kitty.conf" = pkgs.writeText "iris-colors-kitty.conf" fallbackKittyColors;
    "i3-colors.conf" = pkgs.writeText "iris-i3-colors.conf" (
      renderIrisTemplate ../../config/iris/templates/i3-colors.conf
    );
    "colors.rasi" = pkgs.writeText "iris-colors.rasi" (
      renderIrisTemplate ../../config/iris/templates/colors.rasi
    );
    "colors.fish" = pkgs.writeText "iris-colors.fish" (
      renderIrisTemplate ../../config/iris/templates/colors.fish
    );
    "btop.theme" = pkgs.writeText "iris-btop.theme" (
      renderIrisTemplate ../../config/iris/templates/btop.theme
    );
    "skippy-xd.rc" = pkgs.writeText "iris-skippy-xd.rc" (
      renderIrisTemplate ../../config/iris/templates/skippy-xd.rc
    );
    "gtk3-colors.css" = pkgs.writeText "iris-gtk3-colors.css" (
      renderIrisTemplate ../../config/iris/templates/gtk3-colors.css
    );
    "gtk4.css" = pkgs.writeText "iris-gtk4.css" (
      renderIrisTemplate ../../config/iris/templates/gtk4.css
    );
    "notify.css" = pkgs.writeText "iris-notify.css" (
      renderIrisTemplate ../../config/iris/templates/notify.css
    );
  };

  i3ConfigText =
    let
      base = builtins.replaceStrings [ "set $bin ~/.local/bin" ] [ "set $bin ${riceScripts}/bin" ] (
        builtins.readFile ../../config/i3/config
      );
    in
    base + lib.optionalString (cfg.extraI3Config != "") "\n${cfg.extraI3Config}\n";

  fastfetchConfigText = builtins.replaceStrings [ "\"CachyOS_small\"" ] [
    "\"${cfg.fastfetch.logo}\""
  ] (builtins.readFile ../../config/fastfetch/config.jsonc);

  backdropDesktopText =
    builtins.replaceStrings [ "/home/geko/.local/bin/iris-wall" ] [ "${riceScripts}/bin/iris-wall" ]
      (builtins.readFile ../../applications/xfce-backdrop-settings.desktop);

  mkAutostart =
    {
      name,
      comment,
      exec,
      icon,
    }:
    ''
      [Desktop Entry]
      Type=Application
      Name=${name}
      Comment=${comment}
      Exec=${exec}
      Icon=${icon}
      OnlyShowIn=XFCE;
      Terminal=false
    '';

  irisCacheDir = "${config.xdg.cacheHome}/iris";
in
{
  options.rice.xfce-i3 = {
    enable = lib.mkEnableOption "configuração de usuário do rice XFCE + i3";

    enableTerminalStack = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Inclui kitty, fish, starship, zoxide, fzf, eza, fd, btop, fastfetch, yazi e cava.";
    };

    enableNeovim = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Instala neovim com a config LazyVim do repositório (semeando lazy-lock.json como gravável).";
    };

    enableBrilho = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Inclui o script brilho (DDC/CI) e o indicador no painel XFCE.";
    };

    brilhoBus = lib.mkOption {
      type = lib.types.nullOr lib.types.int;
      default = null;
      description = "Barramento I2C do monitor para o ddcutil (null usa detecção automática).";
    };

    dpi = lib.mkOption {
      type = lib.types.nullOr lib.types.int;
      default = null;
      description = "DPI do Xft semeado em xsettings.xml (null mantém o padrão do X11).";
    };

    cursorTheme = lib.mkOption {
      type = lib.types.str;
      default = "Bibata-Modern-Ice";
      description = "Tema de cursor inicial no seed do XFCE.";
    };

    cursorSize = lib.mkOption {
      type = lib.types.int;
      default = 24;
      description = "Tamanho do cursor inicial no seed do XFCE.";
    };

    iconTheme = lib.mkOption {
      type = lib.types.str;
      default = "Papirus";
      description = "Tema de ícones inicial no seed do XFCE.";
    };

    kitty = {
      fontFamily = lib.mkOption {
        type = lib.types.str;
        default = "JetBrainsMono Nerd Font";
        description = "Família de fonte usada no kitty (current-font.conf).";
      };

      fontSize = lib.mkOption {
        type = lib.types.either lib.types.int lib.types.float;
        default = 12;
        description = "Tamanho da fonte usada no kitty (current-font.conf).";
      };
    };

    fastfetch.logo = lib.mkOption {
      type = lib.types.str;
      default = "NixOS_small";
      description = "Logo embutido usado no fastfetch.";
    };

    wallpaperDirs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Diretórios extras de wallpapers passados ao iris-wall via IRIS_WALL_DIRS.";
    };

    initialWallpaper = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Wallpaper inicial gravado em ~/.cache/iris/wallpaper se ainda não houver estado salvo.";
    };

    seedXfce = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Copia configs iniciais do XFCE/Thunar apenas se ainda não existirem em ~/.config.";
    };

    webBrowser = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Navegador padrão escrito em ~/.config/xfce4/helpers.rc durante o seed inicial.";
    };

    extraI3Config = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = "Linhas extras anexadas ao final de ~/.config/i3/config.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages =
      [
        riceScripts
        irisColors
        skippyXd
      ]
      ++ lib.optionals cfg.enableTerminalStack (
        with pkgs;
        [
          kitty
          fish
          starship
          zoxide
          fzf
          eza
          fd
          btop
          fastfetch
          yazi
          cava
        ]
      )
      ++ lib.optional cfg.enableNeovim pkgs.neovim;

    home.sessionVariables = lib.mkIf cfg.enableTerminalStack {
      TERMINAL = lib.mkDefault "kitty";
    };

    xdg.configFile = {
      "i3/config".text = i3ConfigText;
      "picom/picom.conf".source = ../../config/picom/picom.conf;
      "rofi/config.rasi".source = ../../config/rofi/config.rasi;
      "gtk-3.0/gtk.css".source = ../../config/gtk-3.0/gtk.css;
      "iris/templates" = {
        source = ../../config/iris/templates;
        recursive = true;
      };
      "wireplumber/wireplumber.conf.d/51-ryoku-bluetooth.conf".source =
        ../../config/wireplumber/wireplumber.conf.d/51-ryoku-bluetooth.conf;

      "autostart/picom.desktop".text = mkAutostart {
        name = "Compositor (picom)";
        comment = "Sombras, fades, blur e vsync para o i3";
        exec = "${pkgs.picom}/bin/picom --config ${config.xdg.configHome}/picom/picom.conf";
        icon = "preferences-desktop-effects";
      };
      "autostart/iris-wall-restore.desktop".text = mkAutostart {
        name = "Wallpaper + cores (iris)";
        comment = "Reaplica o último wallpaper e o tema gerado pelo iris";
        exec = "${riceScripts}/bin/iris-wall --restore";
        icon = "preferences-desktop-wallpaper";
      };
      "autostart/i3-dynamic-ws.desktop".text = mkAutostart {
        name = "Workspaces dinâmicos (i3)";
        comment = "Mantém os workspaces do i3 numerados em sequência, sem buracos";
        exec = "${riceScripts}/bin/i3-dynamic-ws";
        icon = "preferences-desktop-workspaces";
      };
      "autostart/i3-xfce-wsnames.desktop".text = mkAutostart {
        name = "Nomes de workspace do i3 no painel";
        comment = "Sincroniza os nomes dos workspaces do i3 com o pager do XFCE";
        exec = "${riceScripts}/bin/i3-xfce-wsnames";
        icon = "preferences-desktop-workspaces";
      };
      "autostart/skippy-xd.desktop".text = mkAutostart {
        name = "Overview (skippy-xd)";
        comment = "Daemon do overview: guarda miniaturas das janelas para o Super+Tab";
        exec = ''sh -c "DISPLAY=\\''${DISPLAY%%.0} exec ${skippyXd}/bin/skippy-xd --start-daemon"'';
        icon = "preferences-system-windows";
      };
    }
    // lib.optionalAttrs cfg.enableTerminalStack {
      "kitty/kitty.conf".source = ../../config/kitty/kitty.conf;
      "kitty/current-font.conf".text = ''
        font_family ${cfg.kitty.fontFamily}
        font_size ${toString cfg.kitty.fontSize}
      '';
      "fish/config.fish".source = ../../config/fish/config.fish;
      "starship.toml".source = ../../config/starship.toml;
      "btop/btop.conf".source = ../../config/btop/btop.conf;
      "fastfetch/config.jsonc".text = fastfetchConfigText;
      "yazi" = {
        source = ../../config/yazi;
        recursive = true;
      };
      "cava/config".source = ../../config/cava/config;
      "xdg-terminals.list".source = ../../config/xdg-terminals.list;
    }
    // lib.optionalAttrs cfg.enableNeovim {
      "nvim/init.lua".source = ../../config/nvim/init.lua;
      "nvim/lazyvim.json".source = ../../config/nvim/lazyvim.json;
      "nvim/lua" = {
        source = ../../config/nvim/lua;
        recursive = true;
      };
    };

    xdg.dataFile."applications/xfce-backdrop-settings.desktop".text = backdropDesktopText;

    # Nunca gerenciamos gtk.enable, settings.ini, gtk-4.0/gtk.css, btop/themes/iris.theme
    # nem skippy-xd.rc via symlink do Home Manager, pois o iris-wall reescreve esses arquivos.
    home.activation.riceSeedIrisCache = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      mkdir -p "${irisCacheDir}"
      if [ ! -e "${irisCacheDir}/i3-colors.conf" ]; then
        ${lib.concatStringsSep "\n" (
          lib.mapAttrsToList (name: src: ''
            if [ ! -e "${irisCacheDir}/${name}" ]; then
              install -Dm644 "${src}" "${irisCacheDir}/${name}"
            fi
          '') fallbackIrisFiles
        )}
      fi

      if [ ! -e "${config.xdg.configHome}/btop/themes/iris.theme" ] && [ -e "${irisCacheDir}/btop.theme" ]; then
        install -Dm644 "${irisCacheDir}/btop.theme" "${config.xdg.configHome}/btop/themes/iris.theme"
      fi

      if [ ! -e "${config.xdg.configHome}/skippy-xd/skippy-xd.rc" ] && [ -e "${irisCacheDir}/skippy-xd.rc" ]; then
        install -Dm644 "${irisCacheDir}/skippy-xd.rc" "${config.xdg.configHome}/skippy-xd/skippy-xd.rc"
      fi

      if [ ! -e "${config.xdg.dataHome}/themes/Iris-A/index.theme" ] && [ ! -e "${config.xdg.dataHome}/themes/Iris-B/index.theme" ]; then
        _iris_init="${config.xdg.dataHome}/themes/Iris-A"
        mkdir -p "$_iris_init/gtk-3.0" "$_iris_init/xfce-notify-4.0"
        install -Dm644 "${irisCacheDir}/gtk3-colors.css" "$_iris_init/gtk-3.0/colors.css"
        for _css in gtk.css gtk-dark.css; do
          printf '@import url("file://%s/gtk-3.0/gtk.css");\n@import url("colors.css");\n' \
            "${pkgs.adw-gtk3}/share/themes/adw-gtk3-dark" > "$_iris_init/gtk-3.0/$_css"
        done
        if [ -e "${pkgs.adw-gtk3}/share/themes/adw-gtk3-dark/gtk-3.0/assets" ]; then
          ln -sfn "${pkgs.adw-gtk3}/share/themes/adw-gtk3-dark/gtk-3.0/assets" "$_iris_init/gtk-3.0/assets"
        fi
        install -Dm644 "${irisCacheDir}/notify.css" "$_iris_init/xfce-notify-4.0/gtk.css"
        cat > "$_iris_init/index.theme" <<'EOF'
[Desktop Entry]
Type=X-GNOME-Metatheme
Name=Iris-A
Comment=Tema inicial do iris antes do primeiro papel de parede
EOF
      fi

      ${lib.optionalString (cfg.initialWallpaper != null) ''
        if [ ! -e "${irisCacheDir}/wallpaper" ]; then
          printf '%s\n' "${cfg.initialWallpaper}" > "${irisCacheDir}/wallpaper"
        fi
      ''}
    '';

    home.activation.riceSeedXfce = lib.mkIf cfg.seedXfce (
      lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        ${lib.concatStringsSep "\n" (
          lib.mapAttrsToList (relPath: src: ''
            if [ ! -e "${config.xdg.configHome}/${relPath}" ]; then
              install -Dm644 "${src}" "${config.xdg.configHome}/${relPath}"
            fi
          '') xfceSeed
        )}
      ''
    );

    home.activation.riceSeedNvimLock = lib.mkIf cfg.enableNeovim (
      lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        if [ ! -e "${config.xdg.configHome}/nvim/lazy-lock.json" ]; then
          install -Dm644 "${../../config/nvim/lazy-lock.json}" "${config.xdg.configHome}/nvim/lazy-lock.json"
        fi
      ''
    );
  };
}
