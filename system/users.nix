# Основной пользователь (описание задаётся в хосте)
{ pkgs, user, ... }:

{
  users.users.${user} = {
    isNormalUser = true;
    shell = pkgs.fish;
    extraGroups = [
      "networkmanager"
      "wheel"
      "video"
      "audio"
      "input"
      "kvm"
      "vboxusers"
    ];
  };
}
