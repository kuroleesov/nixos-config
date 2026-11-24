{
  description = "NixOS: Hyprland + Noctalia Shell";

  inputs = {
    # 26.11 (Zokor) ещё не вышла: nixos-unstable; на 26.11 заменить на nixos-26.11 и release-26.11
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-unstable.follows = "nixpkgs";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    claude-desktop = {
      url = "github:csoftware-arigpt/nixos-claude";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # Готовая база для nix-locate и `, <команда>` (comma)
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # ветку nix их CI обновляет на каждый релиз (версия и хеш из подписанного SHA256SUMS); новая версия приходит с `upd`
    keqdroid = {
      url = "github:Lemonochka/keqdroid/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    osu-lazer = {
      url = "github:repinek/osu-lazer-flake";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs =
    { self, nixpkgs, ... }@inputs:
    let
      system = "x86_64-linux";
      lib = nixpkgs.lib;
      pkgs = nixpkgs.legacyPackages.${system};

      # Компьютер = папка в hosts/ (default.nix, hardware-configuration.nix, meta.nix); новые создаёт install.sh
      hosts = lib.attrNames (lib.filterAttrs (_: type: type == "directory") (builtins.readDir ./hosts));

      mkHost =
        host:
        let
          inherit (import ./hosts/${host}/meta.nix) user;
        in
        lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs user; };
          modules = [
            ./hosts/${host}
            inputs.claude-desktop.nixosModules.default
            inputs.home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                backupFileExtension = "hm-backup";
                extraSpecialArgs = { inherit inputs user; };
                users.${user} = import ./home;
              };
            }
          ];
        };
    in
    {
      nixosConfigurations = lib.genAttrs hosts mkHost;

      formatter.${system} = pkgs.nixfmt;

      # nix develop -c ./scripts/update.sh
      devShells.${system}.default = pkgs.mkShell {
        packages = [ pkgs.nh ];
      };
    };
}
