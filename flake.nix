{
  description = "Rice XFCE + i3 (X11) com paleta dinâmica via iris";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
    }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;

      mkNixosCheck =
        {
          system,
          name,
          extraNixos ? { },
          extraHome ? { },
        }:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          sys = nixpkgs.lib.nixosSystem {
            inherit system;
            modules = [
              self.nixosModules.default
              home-manager.nixosModules.home-manager
              (
                { ... }:
                {
                  nixpkgs.overlays = [ self.overlays.default ];
                  system.stateVersion = "25.05";
                  boot.loader.grub.enable = false;
                  fileSystems."/" = {
                    device = "none";
                    fsType = "tmpfs";
                  };
                  networking.hostName = "rice-check";

                  rice.xfce-i3.enable = true;

                  users.users.testuser = {
                    isNormalUser = true;
                    home = "/home/testuser";
                  };

                  home-manager = {
                    useGlobalPkgs = true;
                    useUserPackages = true;
                    users.testuser = {
                      imports = [
                        self.homeManagerModules.default
                        extraHome
                      ];
                      home.stateVersion = "25.05";
                      rice.xfce-i3.enable = true;
                    };
                  };
                }
              )
              extraNixos
            ];
          };
          topDrv = builtins.unsafeDiscardStringContext sys.config.system.build.toplevel.drvPath;
          hmDrv = builtins.unsafeDiscardStringContext sys.config.home-manager.users.testuser.home.activationPackage.drvPath;
        in
        pkgs.runCommand name { } ''
          echo "system=${topDrv}" > "$out"
          echo "home=${hmDrv}" >> "$out"
        '';
    in
    {
      overlays.default = final: _prev: {
        iris-colors = final.callPackage ./nix/pkgs/iris-colors.nix { };
        skippy-xd = final.callPackage ./nix/pkgs/skippy-xd.nix { };
      };

      packages = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          iris-colors = pkgs.callPackage ./nix/pkgs/iris-colors.nix { };
          skippy-xd = pkgs.callPackage ./nix/pkgs/skippy-xd.nix { };
        }
      );

      nixosModules = {
        default = ./nix/modules/nixos.nix;
        xfce-i3 = ./nix/modules/nixos.nix;
      };

      homeManagerModules = {
        default = ./nix/modules/home.nix;
        xfce-i3 = ./nix/modules/home.nix;
      };

      checks = forAllSystems (system: {
        iris-colors = self.packages.${system}.iris-colors;
        skippy-xd = self.packages.${system}.skippy-xd;

        nixos-eval = mkNixosCheck {
          inherit system;
          name = "rice-nixos-eval";
        };

        nixos-eval-brilho = mkNixosCheck {
          inherit system;
          name = "rice-nixos-eval-brilho";
          extraNixos = {
            rice.xfce-i3.enableBrilho = true;
            networking.networkmanager.enable = true;
            hardware.bluetooth.enable = true;
          };
          extraHome = {
            rice.xfce-i3 = {
              enable = true;
              enableBrilho = true;
              dpi = 125;
              webBrowser = "firefox";
              wallpaperDirs = [ "/home/testuser/Wallpapers" ];
              extraI3Config = ''
                # exemplo de regra extra do usuário
                bindsym $mod+Shift+x exec --no-startup-id echo ok
              '';
            };
          };
        };
      });
    };
}
