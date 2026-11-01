-- Cursor
hl.env("XCURSOR_SIZE", "20")
hl.env("HYPRCURSOR_SIZE", "20")

-- Set GDK and XDG variables
hl.env("GDK_BACKEND", "wayland,x11,*")
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")
hl.env("WINIT_UNIX_BACKEND", "wayland")

hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")
-- без него у Dolphin пустые «Открыть с помощью…» и ассоциации файлов
hl.env("XDG_MENU_PREFIX", "plasma-")
