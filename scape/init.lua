local scape = require("scape")

scape.on_startup(function()
    scape.spawn({
        command = "start_scape_systemd_session",
    })
    scape.spawn({
        command = "brave",
    })
    scape.spawn({
        command = "wezterm",
    })
    scape.spawn({
        command = "spotify",
    })
    scape.spawn({
        command = "astal-app",
    })
end)

local space = "main"
local bar_height = 34

scape.on_connector_change(function(outputs)
    local main_output = outputs[1]
    main_output.x = 0
    main_output.y = 0
    main_output.width = outputs[1].width
    main_output.height = outputs[1].height
    main_output.default = true
    main_output.disabled = false
    main_output.scale = 1

    scape.set_layout({
        [space] = {
            main_output,
        },
    })
    scape.set_zones({
        {
            name = "left",
            x = 0,
            y = bar_height,
            width = outputs[1].width / 4,
            height = outputs[1].height - bar_height,
        },
        {
            name = "mid",
            x = outputs[1].width / 4,
            y = bar_height,
            width = outputs[1].width / 2,
            height = outputs[1].height - bar_height,
            default = true,
        },
        {
            name = "right",
            x = outputs[1].width / 4 * 3,
            y = bar_height,
            width = outputs[1].width / 4,
            height = outputs[1].height - bar_height,
        },
        {
            name = "full",
            x = 0,
            y = 0,
            width = outputs[1].width,
            height = outputs[1].height,
        },
    })
end)

scape.map_key({
    key = "1",
    mods = "super",
    callback = function()
        scape.focus_or_spawn("brave", "Brave-browser")
    end,
})
scape.map_key({
    key = "2",
    mods = "super",
    callback = function()
        scape.focus_or_spawn("discord", "discord")
    end,
})
scape.map_key({
    key = "3",
    mods = "super",
    callback = function()
        scape.focus_or_spawn("wezterm", "org.wezfurlong.wezterm")
    end,
})
scape.map_key({
    key = "4",
    mods = "super",
    callback = function()
        scape.focus_or_spawn("thunderbird", "thunderbird")
    end,
})
scape.map_key({
    key = "5",
    mods = "super",
    callback = function()
        scape.focus_or_spawn("dolphin", "dolphin")
    end,
})
scape.map_key({
    key = "6",
    mods = "super",
    callback = function()
        scape.focus_or_spawn("spotify", "Spotify")
    end,
})
scape.map_key({
    key = "7",
    mods = "super",
    callback = function()
        scape.focus_or_spawn("signal-desktop", "Signal")
    end,
})
scape.map_key({
    key = "c",
    mods = "super",
    callback = function()
        scape.focus_or_spawn("qalculate-qt", "qalculate-qt")
    end,
})
scape.map_key({
    key = "j",
    mods = "super",
    callback = function()
        scape.focus_or_spawn("joplin-desktop", "Joplin")
    end,
})
scape.map_key({
    key = "l",
    mods = "super",
    callback = function()
        scape.spawn({ command = "swaylock" })
    end,
})
scape.map_key({
    key = "Left",
    mods = "super",
    callback = function()
        scape.move_to_zone("left")
    end,
})
scape.map_key({
    key = "Right",
    mods = "super",
    callback = function()
        scape.move_to_zone("right")
    end,
})
scape.map_key({
    key = "Up",
    mods = "super",
    callback = function()
        scape.move_to_zone("mid")
    end,
})

scape.map_key({
    key = "s",
    mods = "super",
    callback = function()
        scape.spawn({ command = "make-screenshot" })
    end,
})

scape.map_key({
    key = "F4",
    mods = "alt",
    callback = function()
        scape.close()
    end,
})

scape.map_key({
    key = "XF86_AudioMute",
    callback = function()
        scape.spawn({
            command = "wpctl",
            args = { "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle" },
        })
    end,
})
scape.map_key({
    key = "XF86_AudioRaiseVolume",
    callback = function()
        scape.spawn({
            command = "wpctl",
            args = { "set-volume", "@DEFAULT_AUDIO_SINK@", "5%+" },
        })
    end,
})
scape.map_key({
    key = "XF86_AudioLowerVolume",
    callback = function()
        scape.spawn({
            command = "wpctl",
            args = { "set-volume", "@DEFAULT_AUDIO_SINK@", "5%-" },
        })
    end,
})
scape.map_key({
    key = "XF86_AudioPlay",
    callback = function()
        scape.spawn({
            command = "playerctl",
            args = { "play-pause" },
        })
    end,
})
scape.map_key({
    key = "XF86_AudioNext",
    callback = function()
        scape.spawn({
            command = "playerctl",
            args = { "next" },
        })
    end,
})
scape.map_key({
    key = "XF86_AudioPrev",
    callback = function()
        scape.spawn({
            command = "playerctl",
            args = { "previous" },
        })
    end,
})

scape.map_key({
    key = "d",
    mods = "super",
    callback = function()
        scape.toggle_debug_ui()
    end,
})

scape.window_rule({
    app_id = "Spotify",
    zone = "right",
})

scape.window_rule({
    app_id = "discord",
    zone = "left",
})

scape.window_rule({
    app_id = "steam_app_1286830",
    zone = "full",
})

scape.window_rule({
    app_id = "scape.Scape",
    zone = "left",
})

scape.window_rule({
    app_id = "Signal",
    zone = "left",
})

scape.window_rule({
    app_id = "Joplin",
    zone = "left",
})
