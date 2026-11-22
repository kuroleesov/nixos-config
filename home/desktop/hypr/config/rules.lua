hl.window_rule({ match = { class = "osu!" }, immediate = true }) -- разрешить tearing

hl.window_rule({ match = { class = "librewolf" }, workspace = "1 silent" })

hl.window_rule({ match = { class = "org.telegram.desktop" }, workspace = "2 silent" })
hl.window_rule({ match = { class = "vesktop"}, workspace = "2 silent" })

hl.window_rule({ match = { class = "osu!" }, workspace = "3 silent" })
hl.window_rule({ match = { class = "codium" }, workspace = "3 silent" })
hl.window_rule({ match = { class = "dev.zed.Zed" }, workspace = "3 silent" })

-- OBS Studio: тихо открывается на special:magic, плавающий, фиксированного размера, по центру
hl.window_rule({ match = { class = "com.obsproject.Studio" }, workspace = "special:magic silent" })
hl.window_rule({ match = { class = "com.obsproject.Studio" }, float = true })
hl.window_rule({ match = { class = "com.obsproject.Studio" }, size = { 1200, 700 } })
hl.window_rule({ match = { class = "com.obsproject.Studio" }, center = true })

hl.window_rule({ name = "suppress-maximize", match = { class = ".*" }, suppress_event = "maximize" })
hl.window_rule({
	name = "fix-xwayland-drags",
	match = { class = "^$", title = "^$", xwayland = true, float = true, fullscreen = false, pin = false },
	no_focus = true,
})
hl.window_rule({ match = { class = "^(pavucontrol|org\\.pulseaudio\\.pavucontrol)$" }, float = true })
hl.window_rule({ match = { class = "^(nm-connection-editor|blueman-manager)$" }, float = true })
hl.window_rule({ match = { class = "^(xdg-desktop-portal.*)$" }, float = true })
hl.window_rule({ match = { class = "^(librewolf)$", title = "^(Picture-in-Picture|Картинка в картинке)$" }, float = true, pin = true })
hl.window_rule({ match = { class = "^(thunar)$", title = "^(File Operation Progress)$" }, float = true })

hl.window_rule({ match = { class = "^kitty$" }, float = true, size = { 1100, 650 } })
hl.window_rule({ match = { class = "^com.ayugram.desktop$" }, float = true, size = { 450, 1000 }, move = { 1000, 196 } })
hl.window_rule({ match = { class = "^GStreamer$" }, float = true, move = { 1000, 196 } })
