local App = require("astal.gtk3.app")
local Bar = require("bar")
local Notification = require("notification")

local function get_system_path(path)
    local str = debug.getinfo(2, "S").source:sub(2)
    local src = str:match("(.*/)") or str:match("(.*\\)") or "./"
    return src .. path
end

App:start({
    instance_name = "main",
    css = get_system_path("style.css"),
    request_handler = function(msg, res)
        print(msg)
        res("ok")
    end,
    main = function()
        for _, mon in pairs(App.monitors) do
            Bar(mon)
            Notification(mon)
        end
    end,
})
