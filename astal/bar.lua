local astal = require("astal")
local Widget = require("astal.gtk3.widget")
local Wp = astal.require("AstalWp")
local Variable = astal.Variable
local GLib = astal.require("GLib")
local bind = astal.bind
local Tray = astal.require("AstalTray")

local function SysTray()
    local tray = Tray.get_default()

    return Widget.Box({
        class_name = "SysTray",
        bind(tray, "items"):as(function(items)
            local result = {}
            for i, item in ipairs(items) do
                result[i] = Widget.MenuButton({
                    tooltip_markup = bind(item, "tooltip_markup"),
                    use_popover = false,
                    menu_model = bind(item, "menu-model"),
                    action_group = bind(item, "action-group"):as(function(ag)
                        return { "dbusmenu", ag }
                    end),
                    Widget.Icon({
                        gicon = bind(item, "gicon"),
                    }),
                })
            end
            return result
        end),
    })
end

local function AudioSlider()
    local speaker = Wp.get_default().audio.default_speaker

    return Widget.Box({
        class_name = "AudioSlider",
        css = "min-width: 140px;",
        Widget.Icon({
            icon = bind(speaker, "volume-icon"),
        }),
        Widget.Slider({
            hexpand = true,
            on_dragged = function(self)
                speaker.volume = self.value
            end,
            value = bind(speaker, "volume"),
        }),
    })
end

local function Time(format)
    local time = Variable(""):poll(1000, function()
        return GLib.DateTime.new_now_local():format(format)
    end)

    return Widget.Label({
        class_name = "clock",
        on_destroy = function()
            time:drop()
        end,
        label = time(),
    })
end

return function(gdkmonitor)
    local WindowAnchor = astal.require("Astal", "3.0").WindowAnchor
    local Layer = astal.require("Astal", "3.0").Layer

    Widget.Window({
        class_name = "bar",
        gdkmonitor = gdkmonitor,
        anchor = WindowAnchor.TOP + WindowAnchor.LEFT + WindowAnchor.RIGHT,
        exclusivity = "EXCLUSIVE",
        layer = Layer.BOTTOM,

        Widget.CenterBox({
            Widget.Box({
                halign = "START",
            }),
            Widget.Box({}),
            Widget.Box({
                halign = "END",
                SysTray(),
                AudioSlider(),
                Time("%d.%m.%Y %H:%M"),
            }),
        }),
    })
end
