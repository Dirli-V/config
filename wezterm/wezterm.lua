local wezterm = require("wezterm")
local mux = wezterm.mux
local home_path = os.getenv("HOME") or ""

-- see if the file exists
local function file_exists(file)
	local f = io.open(file, "rb")
	if f then
		f:close()
	end
	return f ~= nil
end

-- get all lines from a file, returns an empty
-- list/table if the file does not exist
local function lines_from(file)
	if not file_exists(file) then
		return {}
	end
	local lines = {}
	for line in io.lines(file) do
		lines[#lines + 1] = line
	end
	return lines
end

local launch_menu = {}
local known_lables = {}
local add_to_launch_menu = function(label, cwd)
	if known_lables[label] ~= nil then
		return
	end
	local counter = #launch_menu + 1
	if counter == 8 then -- Ctrl + 8 does not work in wezterm
		table.insert(launch_menu, {
			label = "Reserved",
			cwd = "",
		})
		counter = counter + 1
	end
	local prefix = ""
	if counter <= 9 then
		prefix = "(" .. counter .. ") "
	else
		prefix = "(F" .. (counter - 9) .. ") "
	end
	counter = counter + 1

	table.insert(launch_menu, {
		label = prefix .. label,
		cwd = cwd,
	})
	known_lables[label] = true
end

add_to_launch_menu("config", home_path .. "/config")
add_to_launch_menu("personal_config", home_path .. "/personal_config")

local project_list = lines_from(home_path .. "/personal_config/projects.txt")
for _, v in pairs(project_list) do
	local sep_index = string.find(v, "=", 1, true)
	local label = string.sub(v, 1, sep_index - 1)
	local cwd = string.sub(v, sep_index + 1)
	add_to_launch_menu(label, cwd:gsub("$HOME", home_path))
end
local dir_list = io.popen("dir -1 ~/repos")
if dir_list ~= nil then
	for dir in dir_list:lines() do
		add_to_launch_menu(dir, home_path .. "/repos/" .. dir)
	end
	dir_list:close()
end

local keys = {
	{ key = "c", mods = "LEADER", action = wezterm.action.SpawnTab("CurrentPaneDomain") },
	{ key = "C", mods = "LEADER", action = wezterm.action.SpawnCommandInNewTab({ args = { "nu" } }) },
	{ key = "x", mods = "LEADER", action = wezterm.action.CloseCurrentTab({ confirm = false }) },
	{ key = "<", mods = "LEADER", action = wezterm.action.MoveTabRelative(-1) },
	{ key = ">", mods = "LEADER", action = wezterm.action.MoveTabRelative(1) },
	{ key = "s", mods = "LEADER", action = wezterm.action.SpawnWindow },
	{ key = "p", mods = "LEADER", action = wezterm.action.ShowLauncher },
	{ key = "z", mods = "LEADER", action = wezterm.action.ShowDebugOverlay },
	{ key = "d", mods = "LEADER", action = wezterm.action.SwitchToWorkspace({
		name = "default",
	}) },
	{ key = "p", mods = "ALT", action = wezterm.action.ShowLauncherArgs({
		flags = "FUZZY|WORKSPACES",
	}) },
	{ key = "z", mods = "LEADER|CTRL", action = wezterm.action.SendKey({ key = "z", mods = "CTRL" }) },
	{ key = "+", mods = "CTRL", action = wezterm.action.IncreaseFontSize },
	{ key = "-", mods = "CTRL", action = wezterm.action.DecreaseFontSize },
	{ key = "v", mods = "LEADER", action = wezterm.action.SplitPane({
		direction = "Right",
	}) },
	{ key = "s", mods = "LEADER", action = wezterm.action.SplitPane({
		direction = "Down",
	}) },
	{ key = "q", mods = "LEADER", action = wezterm.action.CloseCurrentPane({ confirm = false }) },
	{ key = "w", mods = "LEADER", action = wezterm.action.PaneSelect },
	{ key = "r", mods = "LEADER", action = wezterm.action.PaneSelect({
		mode = "SwapWithActive",
	}) },
	{ key = "0", mods = "CTRL", action = wezterm.action.ResetFontSize },
	{ key = "Space", mods = "CTRL", action = wezterm.action.ActivateCopyMode },
	{ key = "c", mods = "CTRL|SHIFT", action = wezterm.action.CopyTo("Clipboard") },
	{ key = "PageUp", mods = "", action = wezterm.action.ScrollByPage(-0.5) },
	{ key = "PageDown", mods = "", action = wezterm.action.ScrollByPage(0.5) },
	{ key = "PageUp", mods = "CTRL", action = wezterm.action.ScrollToPrompt(-1) },
	{ key = "PageDown", mods = "CTRL", action = wezterm.action.ScrollToPrompt(1) },
	{ key = "phys:i", mods = "CTRL", action = wezterm.action.SendString("\x1b[105;5u") },
}
for i = 1, 9 do
	table.insert(keys, {
		key = tostring(i),
		mods = "ALT",
		action = wezterm.action.ActivateTab(i - 1),
	})
end
for i, entry in ipairs(launch_menu) do
	if i <= 9 then
		table.insert(keys, {
			key = tostring(i),
			mods = "CTRL",
			action = wezterm.action.SwitchToWorkspace({
				name = entry.label,
				spawn = entry,
			}),
		})
	else
		local fi = i - 9
		if fi <= 12 then
			table.insert(keys, {
				key = "F" .. tostring(fi),
				mods = "SHIFT",
				action = wezterm.action.SwitchToWorkspace({
					name = entry.label,
					spawn = entry,
				}),
			})
		end
	end
end

wezterm.on("gui-startup", function(_)
	mux.spawn_window({})
	for _, entry in ipairs(launch_menu) do
		mux.spawn_window({
			workspace = entry.label,
			cwd = entry.cwd,
		})
	end
end)

return {
	default_cwd = home_path .. "/repos",
	default_prog = { "nu", "-e", "nd --silent" },
	font = wezterm.font("FiraCode Nerd Font"),
	font_size = 17.0,
	color_scheme = "Catppuccin Mocha",
	launch_menu = launch_menu,
	tab_bar_at_bottom = true,
	leader = { key = "z", mods = "CTRL", timeout_milliseconds = 1000 },
	keys = keys,
	window_padding = {
		left = 0,
		right = 0,
		top = 0,
		bottom = 0,
	},
	harfbuzz_features = { "calt=0", "clig=0", "liga=0" },
	window_frame = {
		active_titlebar_bg = "#1E1E2E",
		inactive_titlebar_bg = "#1E1E2E",
	},
	colors = {
		tab_bar = {
			inactive_tab_edge = "#B4BEFE",
			active_tab = {
				bg_color = "#97CD94",
				fg_color = "#24283b",
			},
			inactive_tab = {
				bg_color = "#89B4FA",
				fg_color = "#24283b",
			},
			new_tab = {
				bg_color = "#89B4FA",
				fg_color = "#24283b",
			},
		},
	},
	enable_csi_u_key_encoding = true,
	check_for_updates = false,
}
