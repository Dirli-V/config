local astal = require("astal")
local Widget = require("astal.gtk3.widget")
local Variable = astal.Variable
local GLib = astal.require("GLib")
local bind = astal.bind
local Tray = astal.require("AstalTray")
local Notifd = require("lgi").require("AstalNotifd")

local notifd = Notifd.get_default()
local notifications = Variable({})

notifd.on_notified = function(_, id)
    local n = notifd:get_notification(id)
    print(n.body, n.summary)
    local current = notifications:get()
    table.insert(current, n)
    notifications:set(current)
end

-- notifd.on_dismissed = function(_, id)
--     print("dismissed", id)
--     local current = notifications:get()
--     for i, n in ipairs(current) do
--         if n.id == id then
--             table.remove(current, i)
--             notifications:set(current)
--             break
--         end
--     end
-- end

local function NotificationIcon(app_entry, app_icon, image)
    if image then
        return Widget.Box({
            css = "background-image: url("
                .. image
                .. ");"
                .. "background-size: contain;"
                .. "background-repeat: no-repeat;"
                .. "background-position: center;",
        })
    end

    local icon = "dialog-information-symbolic"
    -- if Utils.lookUpIcon(app_icon) then
    --     icon = app_icon
    -- end
    --
    -- local app_entry and Utils.lookUpIcon(app_entry) then
    --     icon = app_entry
    -- end

    return Widget.Box({
        child = Widget.Icon(icon),
    })
end

local function Notification(n)
    local icon = Widget.Box({
        vpack = "start",
        class_name = "icon",
        child = NotificationIcon(n),
    })

    local title = Widget.Label({
        class_name = "title",
        xalign = 0,
        justification = "left",
        hexpand = true,
        max_width_chars = 24,
        truncate = "end",
        wrap = true,
        label = n.summary,
        use_markup = true,
    })

    local body = Widget.Label({
        class_name = "body",
        hexpand = true,
        use_markup = true,
        xalign = 0,
        justification = "left",
        label = n.body,
        wrap = true,
    })

    local action_list = {}
    for _, action in ipairs(n.actions) do
        table.insert(
            action_list,
            Widget.Button({
                class_name = "action-button",
                on_clicked = function()
                    n.invoke(action.id)
                    n.dismiss()
                end,
                hexpand = true,
                child = Widget.Label(action.label),
            })
        )
    end

    local actions = Widget.Box({
        class_name = "actions",
        children = action_list,
    })

    return Widget.EventBox({
        attribute = { id = n.id },
        on_primary_click = n.dismiss,
        Widget.Box({
            class_name = "notification " .. n.urgency,
            vertical = true,
            Widget.Box({
                icon,
                Widget.Box({
                    vertical = true,
                    title,
                    body,
                }),
            }),
            actions,
        }),
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

        Widget.Box({
            css = "min-width: 2px; min-height: 2px;",
            class_name = "notifications",
            vertical = true,
            children = notifications(function(current_notifications)
                print("redering")
                local notifcation_widgets = {}
                for _, notification in ipairs(current_notifications) do
                    table.insert(notifcation_widgets, Notification(notification))
                end
                return notifcation_widgets
            end),
        }),
    })
end
