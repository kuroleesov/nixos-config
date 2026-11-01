{ inputs, user, ... }:

{
  nixpkgs.config.allowUnfree = true;
  environment.variables.NIXPKGS_ALLOW_UNFREE = "1";

  # pkgs.unstable.<пакет> — свежие версии из nixos-unstable.
  # Dux Shell (бывший DankMaterialShell) берём оттуда целиком: в 26.05 он старый (dms-shell 1.4).
  nixpkgs.overlays = [
    (final: prev: {
      unstable = import inputs.nixpkgs-unstable {
        inherit (final.stdenv.hostPlatform) system;
        config.allowUnfree = true;
      };
    })
    (final: prev: {
      inherit (final.unstable) dux-shell dux-greeter quickshell;
    })
  ];

  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      auto-optimise-store = true;
      trusted-users = [
        "root"
        "@wheel"
      ];
      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
    # `nix shell nixpkgs#foo` и <nixpkgs> берут тот же nixpkgs, что и система
    registry.nixpkgs.flake = inputs.nixpkgs;
    nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
    channel.enable = false;
  };

  # nh — удобная обёртка над nixos-rebuild (красивый вывод, diff, автоочистка)
  programs.nh = {
    enable = true;
    flake = "/home/${user}/nixos-config";
    clean = {
      enable = true;
      dates = "weekly";
      extraArgs = "--keep-since 14d --keep 5";
    };
  };
}
