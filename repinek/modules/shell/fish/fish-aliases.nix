let
  dotfilesPath = "~/nixos-config";
in {
  btw = "echo I use NixOS, btw";

  # NixOS
  nixos-switch = "sudo nixos-rebuild switch --flake ${dotfilesPath}#pc-1";
  nixos-test = "sudo nixos-rebuild test --flake ${dotfilesPath}#pc-1";
  nixos-vm = "sudo nixos-rebuild build-vm --flake ${dotfilesPath}#pc-1";

  # Nix
  nix-update = "nix flake update";
  nix-search = "nix search nixpkgs";
  nix-gc = "sudo nix-store --gc";

  # Replace ls and tree with eza (a = all, l = long)
  ls = "eza -al --color=auto --group-directories-first --icons=auto";
  la = "eza -a  --color=auto --group-directories-first --icons=auto";
  lt = "eza -aT --color=auto --group-directories-first --icons=auto";
  ld = "eza -a  --color=never | rg '^\\.'";
  tree = "lt";

  # ripgrep shortcuts
  rgi = "rg --ignore-case";
  rgl = "rg --files-with-matches";

  # Use trashy instead of deleting files immediately
  rmt = "trash";
  rml = "trash list";
  rmr = "trash restore";
  rme = "trash empty";

  # Replace cat with bat
  cat = "bat --paging=never --wrap=never --plain";

  # Archive helpers
  untar = "tar -axvf";
  tarnow = "tar -acf";

  # Directories
  dt = "cd ${dotfilesPath}";

  ".." = "cd ..";
  "..." = "cd ../..";
  "...." = "cd ../../..";
  "....." = "cd ../../../..";

  # Other
  exp = "nemo -t $PWD"; # Open Nemo in the current directory
  mkdir = "mkdir -p";
  wget = "wget -c";
  myip = "curl api.ipify.org";
  please = "sudo";
}
