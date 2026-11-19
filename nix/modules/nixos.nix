# Módulo NixOS: configura a base do sistema para o rice XFCE + i3 (X11).
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
in
{
  options.rice.xfce-i3 = {
    enable = lib.mkEnableOption "desktop XFCE + i3 com temas dinâmicos via iris";

    enableDisplayManager = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Habilita LightDM (GTK greeter) com sessão padrão xfce+i3.";
    };

    enableBrilho = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Habilita i2c e ddcutil para controle de brilho do monitor via DDC/CI.";
    };

    installFonts = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Instala Noto Fonts e Nerd Fonts (JetBrainsMono e SpaceMono).";
    };

    installExtraApps = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Instala aplicativos extras do rice (mpv e file-roller).";
    };

    enableTerminalStack = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Habilita o suporte do sistema para fish (além da config de usuário no Home Manager).";
    };
  };

  config = lib.mkIf cfg.enable {
    services.xserver = {
      enable = true;
      desktopManager.xterm.enable = lib.mkDefault false;
      desktopManager.xfce = {
        enable = true;
        # O i3 gerencia janelas (sem xfwm4) e o feh pinta o papel de parede (sem xfdesktop)
        noDesktop = true;
        enableXfwm = false;
      };
      windowManager.i3.enable = true;
    };

    services.displayManager = lib.mkIf cfg.enableDisplayManager {
      defaultSession = lib.mkDefault "xfce+i3";
    };

    services.xserver.displayManager.lightdm = lib.mkIf cfg.enableDisplayManager {
      enable = lib.mkDefault true;
      greeters.gtk.enable = lib.mkDefault true;
    };

    # Como noDesktop = true troca xfce4-pulseaudio-plugin por xfce4-volumed-pulse,
    # excluímos o volumed para evitar conflito com o plugin do painel.
    environment.xfce.excludePackages = [ pkgs.xfce4-volumed-pulse ];

    # O painel e seus plugins precisam ficar em systemPackages no NixOS
    # para serem encontrados em /run/current-system/sw/lib/xfce4/panel/plugins.
    environment.systemPackages =
      with pkgs;
      [
        xfce4-panel
        xfce4-pulseaudio-plugin
        xfce4-clipman-plugin
        xfce4-genmon-plugin
        picom
        rofi
        feh
        jq
        libnotify
        adw-gtk3
        papirus-icon-theme
        bibata-cursors
        xdg-terminal-exec
        xrandr
        xkill
        irisColors
        skippyXd
      ]
      ++ lib.optional cfg.enableBrilho ddcutil
      ++ lib.optionals cfg.installExtraApps [
        mpv
        file-roller
      ];

    programs.thunar.plugins = with pkgs; [
      thunar-archive-plugin
      thunar-volman
    ];

    hardware.i2c.enable = lib.mkIf cfg.enableBrilho (lib.mkDefault true);
    services.blueman.enable = lib.mkIf config.hardware.bluetooth.enable (lib.mkDefault true);
    programs.fish.enable = lib.mkIf cfg.enableTerminalStack (lib.mkDefault true);

    fonts.packages = lib.mkIf cfg.installFonts (
      with pkgs;
      [
        noto-fonts
        nerd-fonts.jetbrains-mono
        nerd-fonts.space-mono
      ]
    );
  };
}
