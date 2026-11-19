hl.config({
    input = {
        -- Раскладка US/RU переключается Shift + Alt
        kb_layout = "us,ru",
        kb_options = "grp:alt_shift_toggle",

        repeat_rate = 50,
        repeat_delay = 250,

        follow_mouse = 1,

        accel_profile = "flat", -- сырой ввод
        force_no_accel = true, -- без ускорения: чувствительность 1:1
        sensitivity = 0,
    },
})
