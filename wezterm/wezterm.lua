local wezterm = require("wezterm")
local home_path = os.getenv("HOME") or ""
local workspaces_path = home_path .. "/.local/share/workspaces.txt"

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

-- the global list of currently active workspaces
local active_workspaces = {}
-- the last activated workspace choice
local current_workspace_choice = nil
local previous_workspace_choice = nil

local function save_current_workspaces()
	local sink = io.open(workspaces_path, "w")
	if not sink then
		return
	end

	for n = 1, 9 do
		if active_workspaces[n] then
			sink:write(active_workspaces[n].id)
		end
		sink:write("\n")
	end

	sink:close()
end

-- insert the given label / cwd into the list of workspaces if not yet present
local add_to_workspaces = function(label, cwd, workspace_choices, known_workspaces)
	if known_workspaces[cwd] ~= nil then
		return
	end
	local workspace_choice = {
		label = wezterm.format({
			{ Foreground = { Color = "green" } },
			{ Text = label },
			"ResetAttributes",
			{ Text = " " },
			{ Foreground = { Color = "orange" } },
			{ Text = "(" },
			"ResetAttributes",
			{ Text = cwd },
			{ Foreground = { Color = "orange" } },
			{ Text = ")" },
		}),
		id = cwd,
	}
	table.insert(workspace_choices, workspace_choice)
	known_workspaces[cwd] = cwd
end

-- add all subfolders to the list of workspaces
local function add_subfolders_to_workspaces(dir, workspace_choices, known_workspaces)
	local dir_list = io.popen("fd --exact-depth 1 -t d --base-directory " .. dir)
	if dir_list ~= nil then
		for subdir in dir_list:lines() do
			local subdirname = subdir:sub(1, -2) --remove trailing /
			add_to_workspaces(subdirname, dir .. "/" .. subdirname, workspace_choices, known_workspaces)
		end
		dir_list:close()
	end
end

-- build the list of available workspaces
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

	return workspace_choices
end

-- restore previous workspaces
local saved_workspaces = lines_from(workspaces_path)
local saved_workspace_index = 1
local available_workspaces = get_workspaces()
for _, saved_workspace in pairs(saved_workspaces) do
	for _, available_workspace in pairs(available_workspaces) do
		if available_workspace.id == saved_workspace then
			active_workspaces[saved_workspace_index] = available_workspace
		end
	end
	saved_workspace_index = saved_workspace_index + 1
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
			local choices = get_workspaces()
			window:perform_action(
				wezterm.action.InputSelector({
					action = wezterm.action_callback(function(inner_window, inner_pane, id, label)
						if not id or not label then
							return
						end
						current_workspace_choice = { id = id, label = label }
						inner_window:perform_action(
							wezterm.action.SwitchToWorkspace({
								name = id,
								spawn = {
									cwd = id,
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
	{
		key = "z",
		mods = "ALT",
		action = wezterm.action_callback(function(window, pane)
			local choices = {}
			for n = 1, 9 do
				if active_workspaces[n] then
					table.insert(choices, { id = tostring(n), label = active_workspaces[n].label })
				else
					table.insert(choices, {
						id = tostring(n),
						label = wezterm.format({
							{ Foreground = { Color = "purple" } },
							{ Text = tostring(n) },
							"ResetAttributes",
							{ Text = ": <empty>" },
						}),
					})
				end
			end

			window:perform_action(
				wezterm.action.InputSelector({
					action = wezterm.action_callback(function(_, _, id, _)
						if not id then
							return
						end
						active_workspaces[tonumber(id)] = current_workspace_choice
						save_current_workspaces()
					end),
					title = "Assign current workspace to slot",
					choices = choices,
					fuzzy = true,
				}),
				pane
			)
		end),
	},
	-- go to previous workspace
	{
		key = "h",
		mods = "ALT",
		action = wezterm.action_callback(function(window, pane)
			if not previous_workspace_choice or not current_workspace_choice then
				return
			end

			local tmp = current_workspace_choice
			current_workspace_choice = previous_workspace_choice
			previous_workspace_choice = tmp

			window:perform_action(
				wezterm.action.SwitchToWorkspace({
					name = previous_workspace_choice.id,
					spawn = {
						cwd = previous_workspace_choice.id,
					},
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
	{
		key = "Space",
		mods = "CTRL|SHIFT",
		action = wezterm.action.QuickSelectArgs({
			action = wezterm.action.CopyTo("Clipboard"),
		}),
	},
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
	-- activate workspace for this slot if there is one
	if active_workspaces[i] then
		previous_workspace_choice = current_workspace_choice
		current_workspace_choice = active_workspaces[i]
		window:perform_action(
			wezterm.action.SwitchToWorkspace({
				name = active_workspaces[i].id,
				spawn = {
					cwd = active_workspaces[i].id,
				},
			}),
			pane
		)
		return
	end

	-- spawn new workspace in current slot
	local choices = get_workspaces()
	window:perform_action(
		wezterm.action.InputSelector({
			action = wezterm.action_callback(function(inner_window, inner_pane, id, label)
				if not id or not label then
					return
				end

				current_workspace_choice = { id = id, label = label }
				active_workspaces[i] = current_workspace_choice
				save_current_workspaces()
				inner_window:perform_action(
					wezterm.action.SwitchToWorkspace({
						name = id,
						spawn = {
							cwd = id,
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
		TERM = "wezterm",
		TERMINFO = home_path .. "/.nix-profile/share/terminfo",
	},
	term = "wezterm",
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
	warn_about_missing_glyphs = false,
}
