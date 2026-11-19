# Exemplo mínimo de flake NixOS usando este rice (XFCE + i3 + iris + Home Manager).
# Troque a URL do input `rice`, o nome do host e o usuário antes de aplicar.
{
  description = "Host NixOS com o rice XFCE + i3";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    rice = {
      # Em um repositório clonado localmente use, por exemplo: path:/home/seu-usuario/rice
      url = "github:SEU-USUARIO/rice";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      rice,
      ...
    }:
    {
      nixosConfigurations.meu-pc = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          # ./hardware-configuration.nix
          rice.nixosModules.default
          home-manager.nixosModules.home-manager
          {
            networking.hostName = "meu-pc";
            system.stateVersion = "25.05";

            # Opcional: expõe pkgs.iris-colors e pkgs.skippy-xd no sistema todo
            nixpkgs.overlays = [ rice.overlays.default ];

            # Base do sistema (X11, XFCE sem xfwm4/xfdesktop, i3, painel, picom, fontes...)
            rice.xfce-i3 = {
              enable = true;
              # Ative se usar monitor externo com DDC/CI (também adicione seu usuário ao grupo "i2c")
              enableBrilho = false;
            };

            users.users.seu-usuario = {
              isNormalUser = true;
              extraGroups = [
                "wheel"
                "networkmanager"
                # "i2c" # necessário se enableBrilho = true
              ];
            };

            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.seu-usuario = {
                imports = [ rice.homeManagerModules.default ];
                home.stateVersion = "25.05";

                rice.xfce-i3 = {
                  enable = true;
                  # Opcionais úteis:
                  # dpi = 125;
                  # webBrowser = "firefox";
                  # wallpaperDirs = [ "/home/seu-usuario/Pictures/Wallpapers" ];
                  # initialWallpaper = /home/seu-usuario/Pictures/Wallpapers/padrao.jpg;
                };
              };
            };
          }
        ];
      };
    };
}
