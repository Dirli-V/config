local wezterm = require("wezterm")
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

-- insert the given label / cwd into the list of workspaces if not yet present
local add_to_workspaces = function(label, cwd, workspace_choices, known_workspaces)
	if known_workspaces[cwd] ~= nil then
		return
	end
	local workspace_choice = {
		label = label,
		id = cwd,
	}
	table.insert(workspace_choices, workspace_choice)
	known_workspaces[cwd] = cwd
end

-- add all subfolders to the list of workspaces
local function add_subfolders_to_workspaces(dir, workspace_choices, known_workspaces)
	local dir_list = io.popen("dir -1 " .. dir)
	if dir_list ~= nil then
		for subdir in dir_list:lines() do
			add_to_workspaces(subdir, dir .. "/" .. subdir, workspace_choices, known_workspaces)
		end
		dir_list:close()
	end
end

-- build the list workspaces
local function get_workspaces()
	local workspace_choices = {}
	local known_workspaces = {}

	local project_list = lines_from(home_path .. "/personal_config/projects.txt")
	for _, v in pairs(project_list) do
		local sep_index = string.find(v, "=", 1, true)
		local label = string.sub(v, 1, sep_index - 1)
		local cwd = string.sub(v, sep_index + 1)
		local project_path = cwd:gsub("$HOME", home_path)
		if file_exists(project_path) then
			if label == "*" then
				add_subfolders_to_workspaces(project_path, workspace_choices, known_workspaces)
			else
				add_to_workspaces(label, project_path, workspace_choices, known_workspaces)
			end
		end
	end

	return workspace_choices, known_workspaces
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
	{
		key = "p",
		mods = "ALT",
		action = wezterm.action_callback(function(window, pane)
			local choices, workspace_to_cwd = get_workspaces()
			window:perform_action(
				wezterm.action.InputSelector({
					action = wezterm.action_callback(function(inner_window, inner_pane, id, label)
						if not id or not label then
							return
						end
						inner_window:perform_action(
							wezterm.action.SwitchToWorkspace({
								name = label,
								spawn = {
									cwd = workspace_to_cwd[id],
								},
							}),
							inner_pane
						)
					end),
					title = "Switch to workspace",
					choices = choices,
					fuzzy = true,
				}),
				pane
			)
		end),
	},
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
-- open a workspace based on the given index
local function open_workspace(window, pane, i)
	local workspace_choices, workspace_to_cwd = get_workspaces()
	local entry = workspace_choices[i]
	window:perform_action(
		wezterm.action.SwitchToWorkspace({
			name = entry.label,
			spawn = {
				cwd = workspace_to_cwd[entry.id],
			},
		}),
		pane
	)
end
for i = 1, 9 + 12 do
	local workspace_index = i
	if i > 8 then
		workspace_index = workspace_index - 1
	end
	if i <= 9 then
		if i == 8 then -- CTRL + 8 does not work
			goto continue
		end
		table.insert(keys, {
			key = tostring(i),
			mods = "CTRL",
			action = wezterm.action_callback(function(window, pane)
				open_workspace(window, pane, workspace_index)
			end),
		})
	else
		local fi = i - 9
		if fi <= 12 then
			table.insert(keys, {
				key = "F" .. tostring(fi),
				mods = "SHIFT",
				action = wezterm.action_callback(function(window, pane)
					open_workspace(window, pane, workspace_index)
				end),
			})
		end
	end
	::continue::
end

return {
	default_cwd = home_path .. "/repos",
	default_prog = { "nu", "-e", "nd --silent" },
	set_environment_variables = {
		TERM = "alacritty",
	},
	font = wezterm.font("FiraCode Nerd Font"),
	font_size = 17.0,
	color_scheme = "Catppuccin Mocha",
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
