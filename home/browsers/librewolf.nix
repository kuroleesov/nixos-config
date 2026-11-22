# LibreWolf: профиль, расширения, userChrome/userContent и поисковые движки
{ pkgs, inputs, ... }:
{
  # Отключение штатных горячих клавиш (в модуле firefox home-manager такой опции нет)
  home.file.".librewolf/pc-1/customKeys.json" = {
    force = true;
    text = builtins.toJSON {
      key_search = { };
      key_search2 = { };
      printKb = { };
      key_savePage = { };
      key_closeWindow = { };
      openFileKb = { };
      key_privatebrowsing = { };
      key_newNavigator = { };
      focusURLBar2 = { };
      key_switchTextDirection = { };
      key_findAgain2 = { };
      key_findPrevious2 = { };
      key_gotoHistory = { };
      viewBookmarksSidebarKb = { };
      viewGenaiChatSidebarKb = { };
      viewOpenTabsSidebarKb = { };
      toggleSidebarKb = { };
      key_toggleReaderMode = { };
      key_togglePictureInPicture = { };
      viewBookmarksToolbarKb = { };
      key_sanitize = { };
      bookmarkAllTabsKb = { };
      key_openAddons = { };
      key_viewInfo = { };
      key_screenshot = { };
    };
  };

  programs.librewolf = {
    enable = true;

    languagePacks = [
      "en-GB"
      "ru"
    ];

    # Хост Pywalfox встроен в Noctalia; `noctalia firefox-theme` пишет манифест только в ~/.mozilla и к старому пути в /nix/store
    nativeMessagingHosts = [
      (pkgs.writeTextDir "lib/mozilla/native-messaging-hosts/pywalfox.json" (
        builtins.toJSON {
          name = "pywalfox";
          description = "Noctalia Firefox theme native messaging host";
          path = "${pkgs.noctalia}/bin/.noctalia-wrapped";
          type = "stdio";
          allowed_extensions = [ "pywalfox@frewacom.org" ];
        }
      ))
    ];

    profiles."pc-1" = {
      id = 0;
      name = "pc-1";
      isDefault = true;

      # Часть правил взята из https://git.symlinx.net/daccfiles/tree/.config/browser_stuff/
      # и https://github.com/mbnuqw/sidebery#how-to-hide-native-tabs
      userChrome = ''
        /* Fix bookmarks tab color after Nova redesign */
        :root[customtitlebar] #navigator-toolbox[tabs-hidden] > #PersonalToolbar {
          background-color: transparent !important;
          color: inherit !important;
        }

        /* Themed (pywalfox) right-click menu */
        .menupopup-arrowscrollbox {
          background: var(--lwt-accent-color) !important;
          color: var(--lwt-text-color) !important;
        }

        menupopup menu,
        menupopup menuitem {
          color: var(--lwt-text-color) !important;
        }

        menupopup menu[_moz-menuactive="true"]:not([disabled="true"]),
        menupopup menuitem[_moz-menuactive="true"]:not([disabled="true"]) {
          background: color-mix(
            in srgb,
            var(--lwt-accent-color) 82%,
            var(--lwt-text-color)
          ) !important;
        }

        /* Sidebery (messy) */
        /* Hide sidebar-panel-header (sidebar.revamp: true) */
        #sidebar-panel-header {
          display: none !important;
        }

        #main-window {
          /* Hide horizontal native tabs toolbar */
          #TabsToolbar >* {
            display: none !important;
          }

          /* Hide new Firefox sidebar, restyle addon's sidebar */
          #sidebar-main, #sidebar-container, #sidebar-launcher-splitter {
            display: none !important;
          }
          #sidebar-box {
            padding: 0 !important;
            border-radius: 0 !important;
            border: none !important;
          }
          #sidebar-box #sidebar {
            box-shadow: none !important;
            border: none !important;
            outline: none !important;
            border-radius: 0 !important;
          }
          #sidebar-splitter {
            --splitter-width: 3px !important;
            min-width: var(--splitter-width) !important;
            width: var(--splitter-width) !important;
            padding: 0 !important;
            margin: 0 calc(-1*var(--splitter-width) + 1px) 0 0 !important;
            border: 0 !important;
            opacity: 0 !important;
          }
        }

        /* Global corner radius (Maybe some day I will put 0px here) */
        * { border-radius: 4px !important; }

        /* Hide close firefox button (not tab) */
        .titlebar-buttonbox-container {
            display: none !important;
        }
      '';

      userContent = ''
        @-moz-document url-prefix("about:") {
          * {
            border-radius: 4px !important;
          }

          /* Hide settings button */
          .personalizeButtonWrapper {
            display: none !important;
          }
        }
      '';

      extensions.packages = with inputs.firefox-addons.packages.x86_64-linux; [
        vimium
        ublock-origin
        darkreader
        proton-pass
        refined-github
        # только цвета: CSS-тему Noctalia в userChrome не подключаем, она портит интерфейс
        pywalfox
        clearurls
        sidebery

      ];

      # Настройки дополнений, которые задаются вручную (не заданные = по умолчанию):
      # - Vimium: IgnoreKeyboardLayout = true; NewTabDestination = browserNewTabPage
      # - uBlock Origin: облачное хранилище, свой accent color, блокировка удалённых шрифтов
      #   и отключение JavaScript включены; из списков фильтров включено всё,
      #   кроме Experimental и региональных
      # - Pywalfox: Fetch colors on startup = true; Use DuckDuckGo theme = true
      # - Dark Reader: Enable by default = false; Detect dark theme = false
      # - Sidebery: Custom CSS
      #     #root.root {--toolbar-bg: var(--lwt-accent-color);}
      #     #root.root {--general-border-radius: 4px;}

      # Закладки синхронизируются через аккаунт Firefox

      settings = {
        "intl.locale.requested" = "ru,en-US"; # запасной (второй) язык, если перевод на первом неполный

        "extensions.autoDisableScopes" = 0; # автоматически включать дополнения

        "sidebar.revamp" = true;
        "sidebar.verticalTabs" = true;
        "sidebar.verticalTabs.dragToPinPromo.dismissed" = true;

        "toolkit.legacyUserProfileCustomizations.stylesheets" = true; # включить userChrome.css и userContent.css

        "browser.startup.page" = 3; # открывать прошлые окна и вкладки
        "browser.sessionstore.newTabOnRestore" = true; # плюс новая вкладка
        "browser.settings-redesign.promo.dismissed" = true;
        "browser.toolbars.bookmarks.visibility" = "newtab";
        "browser.compactmode.show" = true;
        "browser.uidensity" = 1;
        "browser.uiCustomization.navBarWhenVerticalTabs" = ''
          ["reset-pbm-toolbar-button","back-button","forward-button","vertical-spacer","customizableui-special-spring4","customizableui-special-spring5","customizableui-special-spring6","urlbar-container","customizableui-special-spring9","customizableui-special-spring8","customizableui-special-spring7","downloads-button","unified-extensions-button"]
        '';
        "browser.uiCustomization.state" = ''
          {"placements":{"widget-overflow-fixed-list":[],"unified-extensions-area":["_3c078156-979c-498b-8990-85f7987dd929_-browser-action","_d7742d87-e61d-4b78-b8a1-b469842139fa_-browser-action","ublock0_raymondhill_net-browser-action","pywalfox_frewacom_org-browser-action","78272b6fa58f4a1abaac99321d503a20_proton_me-browser-action","_a4c4eda4-fb84-4a84-b4a1-f7c1cbf2a1ad_-browser-action","addon_darkreader_org-browser-action","_e844d8ad-7f10-4de7-ad36-13c95d10aae4_-browser-action","_74145f27-f039-47ce-a470-a662b129930a_-browser-action"],"nav-bar":["ai-window-toggle","reset-pbm-toolbar-button","back-button","forward-button","vertical-spacer","customizableui-special-spring4","customizableui-special-spring5","customizableui-special-spring6","urlbar-container","customizableui-special-spring9","customizableui-special-spring8","customizableui-special-spring7","downloads-button","unified-extensions-button"],"toolbar-menubar":["menubar-items"],"TabsToolbar":[],"vertical-tabs":["tabbrowser-tabs"],"PersonalToolbar":["personal-bookmarks"]},"seen":["reset-pbm-toolbar-button","pywalfox_frewacom_org-browser-action","78272b6fa58f4a1abaac99321d503a20_proton_me-browser-action","_a4c4eda4-fb84-4a84-b4a1-f7c1cbf2a1ad_-browser-action","_d7742d87-e61d-4b78-b8a1-b469842139fa_-browser-action","addon_darkreader_org-browser-action","ublock0_raymondhill_net-browser-action","developer-button","screenshot-button","_e844d8ad-7f10-4de7-ad36-13c95d10aae4_-browser-action","_3c078156-979c-498b-8990-85f7987dd929_-browser-action","_74145f27-f039-47ce-a470-a662b129930a_-browser-action"],"dirtyAreaCache":["unified-extensions-area","nav-bar","TabsToolbar","vertical-tabs","toolbar-menubar","PersonalToolbar"],"currentVersion":26,"newElementCount":11}
        '';
        "browser.translations.automaticallyPopup" = false;
        "browser.search.suggest.enabled" = true;
        "browser.urlbar.suggest.searches" = true;
        "browser.nova.enabled" = false; # новый редизайн Firefox: about-страницы лучше, но остальное (например, строка поиска) хуже

        "findbar.highlightAll" = true; # подсвечивать все совпадения в Ctrl+F

        "media.videocontrols.picture-in-picture.video-toggle.enabled" = false; # не пользуюсь

        "layout.css.devPixelsPerPx" = 1.2;

        "privacy.resistFingerprinting" = true;
        "privacy.resistFingerprinting.letterboxing" = true;
        "privacy.sanitize.sanitizeOnShutdown" = false;

        # Trusted Recursive Resolver (DNS over HTTPS)
        # 0 - по умолчанию, 2 - пробовать DoH, при сбое системный DNS
        # 3 - только DoH, без запасного варианта
        # 5 - DoH выключен, системный DNS
        "network.trr.mode" = 5;

        "identity.fxaccounts.enabled" = true;
        "services.sync.declinedEngines" = "addons,prefs,addresses,creditcards,passwords"; # синхронизировать только закладки, открытые вкладки и историю

      };

      search = {
        default = "ddg";
        force = true;

        engines = {
          # Поиск по пакетам и опциям Nix
          nix-packages = {
            name = "Nix packages";
            urls = [
              {
                template = "https://search.nixos.org/packages";
                params = [
                  {
                    name = "type";
                    value = "packages";
                  }
                  {
                    name = "channel";
                    value = "unstable";
                  }
                  {
                    name = "query";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];

            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "@np" ];
          };

          nixos-options = {
            name = "NixOS options";
            urls = [
              {
                template = "https://search.nixos.org/options";
                params = [
                  {
                    name = "type";
                    value = "options";
                  }
                  {
                    name = "channel";
                    value = "unstable";
                  }
                  {
                    name = "query";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];

            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake-white.svg";
            definedAliases = [ "@no" ];
          };

          nix-hm-options = {
            name = "Nix Home Manager options";
            urls = [
              {
                template = "https://search.nixos.org/options";
                params = [
                  {
                    name = "type";
                    value = "options";
                  }
                  {
                    name = "channel";
                    value = "unstable";
                  }
                  {
                    name = "source";
                    value = "home_manager";
                  }
                  {
                    name = "query";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];

            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake-white.svg";
            definedAliases = [ "@hm" ];
          };

          github = {
            name = "GitHub repos";
            urls = [
              {
                template = "https://github.com/search";
                params = [
                  {
                    name = "q";
                    value = "{searchTerms}";
                  }
                  {
                    name = "type";
                    value = "repositories";
                  }
                ];
              }
            ];

            icon = "https://github.githubassets.com/favicons/favicon.svg";
            definedAliases = [
              "@gh"
              "@git"
            ];
          };

          youtube = {
            name = "Youtube";
            urls = [
              {
                template = "https://www.youtube.com/results";
                params = [
                  {
                    name = "search_query";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];

            icon = "https://www.google.com/s2/favicons?domain=youtube.com";
            definedAliases = [ "@yt" ];
          };

          # Скрыть mojeek и startpage
          mojeek.metaData.hidden = true;
          startpage.metaData.hidden = true;
        };
      };
    };
  };
}
