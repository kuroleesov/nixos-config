# Игры: osu!lazer, Touhou (thcrap через Proton), Steam Guard
{
  config,
  inputs,
  pkgs,
  ...
}:
let
  thcrapProton = pkgs.unstable.thcrap-steam-proton-wrapper.overrideAttrs (old: {
    postPatch = (old.postPatch or "") + ''
      substituteInPlace thcrap_proton \
        --replace-fail "run '\$THPRAC_FOLDER/thprac.exe'" "run '\$THPRAC_FOLDER/thprac.exe' --attach"
    '';
  });
in
{
  imports = [ inputs.osu-lazer.homeManagerModules.osu-lazer ];

  home.packages = [
    # Для игры с Double Time
    pkgs.gammastep
    pkgs.steamguard-cli
    thcrapProton
    pkgs.zenity # Нужен thcrap_proton для диалогов настройки и ошибок
  ];

  # Скрываем gammastep-indicator из меню приложений
  xdg.dataFile."applications/gammastep-indicator.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=Gammastep Indicator
    Hidden=true
  '';

  programs.osu-lazer = {
    enable = true;

    nativeWayland = true;
    extraShellArgs = [
      "--set"
      "OSU_SDL3"
      "1"
      "--set"
      "SDL_VIDEO_DOUBLE_BUFFER"
      "1"
    ];
    channel = "tachyon";
    useGamemode = true;

    storagePath = "${config.home.homeDirectory}/Games/osu!";

    files."${config.home.homeDirectory}/Games/osu!" = {
      gameSettings = {
        # Общие
        Prefer24HourTime = true;
        ReleaseStream = "Tachyon";

        # Ввод
        MouseDisableButtons = true;
        MouseDisableWheel = true;

        # Интерфейс
        UIHoldActivationDelay = 0.0;
        IntroSequence = "Random";
        SeasonalBackgroundMode = "Always";
        ShowConvertedBeatmaps = false;
        ModSelectHotkeyStyle = "Classic";
        ModSelectTextSearchStartsActive = false;
        SongSelectBackgroundBlur = true;

        # Геймплей
        HitLighting = false;
        StarFountains = false;
        DimLevel = 1.0;
        FadePlayfieldWhenHealthLow = false;
        BeatmapSkins = false;
        BeatmapColours = false;
        BeatmapHitsounds = false;
        ShowStoryboard = false;
        KeyOverlay = true;
        GameplayLeaderboard = false;
        AutoCursorSize = true;
        # Скорость прокрутки в mania: 26.5

        # Графика
        UIScale = 0.95;

        # Онлайн
        PreferNoVideo = true;
        ShowOnlineExplicitContent = true;
        NotifyOnFriendPresenceChange = true;

        # Нет в настройках игры
        # Выбор песни
        BeatmapDetailTab = "Local";

        # Список битмапов
        BeatmapListingFeaturedArtistFilter = false;

        # Профиль
        ProfileCoverExpanded = false;

        # Редактор
        EditorDim = 1.0;

        # Мультиплеер
        MultiplayerRoomFilter = "Public";
      };

      frameworkSettings = {
        FrameSync = "Unlimited";
        Locale = "ru";
      };
    };
  };
}
