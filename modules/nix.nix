{ inputs, user, ... }:

{
  nixpkgs.config.allowUnfree = true;
  # claude-desktop тянет electron 42 (EOL в nixpkgs); убрать, когда модуль перейдёт на новый electron
  nixpkgs.config.permittedInsecurePackages = [ "electron-42.11.18" ];
  environment.variables.NIXPKGS_ALLOW_UNFREE = "1";

  # pkgs.unstable.<пакет> — свежие версии из nixos-unstable.
  nixpkgs.overlays = [
    (final: prev: {
      unstable = import inputs.nixpkgs-unstable {
        inherit (final.stdenv.hostPlatform) system;
        config.allowUnfree = true;
        overlays = [
          (f: p: {
            # Сломано в nixpkgs, убрать, когда починят: новый hatchling требует tomlkit, которого нет
            # в офлайн-наборе колёс anki, а cargo-хук теперь берёт zstd/sqlite/lzma/openssl из системы
            anki = p.anki.overrideAttrs (old: {
              nativeBuildInputs = old.nativeBuildInputs ++ [ f.pkg-config ];
              buildInputs = old.buildInputs ++ [ f.zstd f.sqlite f.xz f.openssl ];
              env = old.env // {
                UV_FIND_LINKS = f.symlinkJoin {
                  name = "uv-wheels";
                  paths = [ old.env.UV_FIND_LINKS p.anki.python.pkgs.tomlkit.dist ];
                };
              };
            });
          })
        ];
      };
    })
    (final: prev: {
      # Noctalia v5: в 26.05 старая 5.0, дотфайлы рассчитаны на версию из unstable
      inherit (final.unstable) noctalia;
      il2cpp-inspector-redux = final.callPackage ../repinek/pkgs/il2cpp-inspector-redux { };
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
