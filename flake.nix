{
  description = "NixOS: Hyprland + Dux Shell";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
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
  };

  outputs =
    { self, nixpkgs, ... }@inputs:
    let
      system = "x86_64-linux";
      user = "pc-1";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      nixosConfigurations.pc-1 = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs user; };
        modules = [
          ./hosts/pc-1
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

      formatter.${system} = pkgs.nixfmt;

      # nix develop -c ./scripts/update.sh
      devShells.${system}.default = pkgs.mkShell {
        packages = [ pkgs.nh ];
      };
    };
}
