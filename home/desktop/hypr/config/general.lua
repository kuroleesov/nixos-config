hl.config({
    general = {
        layout = "dwindle",

        gaps_in = 0,
        gaps_out = 0,

        border_size = 2,

        allow_tearing = true,
    },

    decoration = {
        rounding = 0,
        rounding_power = 1,

        shadow = {
            enabled = true,
            range = 4,
            render_power = 3,
        },

        blur = {
            enabled = true,
            size = 3,
            passes = 3,

            vibrancy = 0.1696,
        },
    },

    dwindle = {
        preserve_split = true,
        special_scale_factor = 0.9, -- для scratchpad
    },

    misc = {
        disable_hyprland_logo = true,
        force_default_wallpaper = 0,
        focus_on_activate = true,
        vrr = 0, -- 0 выкл, 1 вкл, 2 только полноэкранные, 3 полноэкранное видео или игры
    },

    render = {
        direct_scanout = 1, -- 0 выкл, 1 вкл, 2 только полноэкранные игры
    },

    ecosystem = {
        no_update_news = true,
    },

    cursor = {
        no_hardware_cursors = true, -- NVIDIA: без этого курсор может мерцать/пропадать
    },
})

-- Анимации Material 3 Expressive (из github.com/deadinside28/nixos-config).
-- Пружины пересчитаны из токенов Android: c = 2·ζ·√k при массе 1;
-- у пружин speed не используется, длительность берётся из физики.

-- «Пространственные» пружины: движение и масштаб
hl.curve("m3DefaultSpatial", { type = "spring", mass = 1, stiffness = 380, dampening = 31.19 }) -- ζ 0.8
hl.curve("m3SlowSpatial", { type = "spring", mass = 1, stiffness = 200, dampening = 22.63 }) -- ζ 0.8, полноэкранное
-- ζ 1.0: окно доходит до места без перелёта и дрожи текста в конце
hl.curve("m3DefaultSpatialCalm", { type = "spring", mass = 1, stiffness = 380, dampening = 38.99 })
-- «Эффектные» пружины: прозрачность и цвет, без отскока
hl.curve("m3DefaultEffects", { type = "spring", mass = 1, stiffness = 1600, dampening = 80 })
hl.curve("m3FastEffects", { type = "spring", mass = 1, stiffness = 3800, dampening = 123.29 })
-- уход с экрана — ускоряющаяся кривая, появление — быстрый старт и мягкое торможение
hl.curve("m3EmphasizedAccel", { type = "bezier", points = { { 0.3, 0 }, { 0.8, 0.15 } } })
hl.curve("m3EmphasizedDecel", { type = "bezier", points = { { 0.05, 0.7 }, { 0.1, 1 } } })
hl.curve("m3Standard", { type = "bezier", points = { { 0.2, 0 }, { 0, 1 } } })

local animations = {
    { leaf = "global", enabled = true, speed = 3, bezier = "m3Standard" },
    { leaf = "windowsIn", enabled = true, speed = 4, bezier = "m3EmphasizedDecel", style = "popin 85%" },
    { leaf = "windowsOut", enabled = true, speed = 2, bezier = "m3EmphasizedAccel", style = "popin 85%" },
    { leaf = "windowsMove", enabled = true, speed = 3, spring = "m3DefaultSpatialCalm" },
    { leaf = "fadeIn", enabled = true, speed = 2, spring = "m3DefaultEffects" },
    { leaf = "fadeOut", enabled = true, speed = 1.5, bezier = "m3EmphasizedAccel" },
    { leaf = "fadeSwitch", enabled = true, speed = 2, spring = "m3DefaultEffects" },
    { leaf = "fadeDim", enabled = true, speed = 2, spring = "m3DefaultEffects" },
    { leaf = "border", enabled = true, speed = 2, spring = "m3FastEffects" },
    -- воркспейсы: M3 «shared axis» по вертикали
    { leaf = "workspaces", enabled = true, speed = 4, spring = "m3SlowSpatial", style = "slidefadevert 15%" },
    { leaf = "specialWorkspace", enabled = true, speed = 4, spring = "m3SlowSpatial", style = "slidefadevert 20%" },
    { leaf = "zoomFactor", enabled = true, speed = 3, spring = "m3DefaultSpatial" },
    { leaf = "layers", enabled = true, speed = 2, spring = "m3DefaultEffects" },
    { leaf = "layersIn", enabled = true, speed = 2, spring = "m3DefaultEffects", style = "fade" },
    { leaf = "layersOut", enabled = true, speed = 1.5, bezier = "m3EmphasizedAccel", style = "fade" },
}

for _, animation in ipairs(animations) do
    hl.animation(animation)
end
