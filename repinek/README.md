Источник: https://github.com/repinek/nixos-dotfiles, коммит 4b1533d, лицензия MIT (см. LICENSE).
Файлы скопированы из upstream и пропатчены под pc-1; остальное из upstream не берётся.
Локальные правки:

- nemo: убран `~/.hidden` (он скрывал бы ~/Pictures)
- fish: не логин-шелл (остаётся zsh); алиасы указывают на `~/nixos-config#pc-1`
- osu!lazer: путь через `config.home.homeDirectory`, локаль `ru`; beets: `~/Music`
- librewolf: профиль `pc-1`, язык `ru,en-US`; zed: без wakatime, hyprland из `pkgs.unstable`
- libreoffice, anki, touhou: пакеты из `pkgs.unstable`; шрифт google-sans убран
- noctalia: без аватара, локация Москва, свой шаблон kitty (`templates/kitty.nix`)
