local lum = require("lumalla")

--- Tracked "main" camera into the scene (source rect) for the primary output.
--- Updated by view-move mode; logo+r restores current lane view.
local main_view = nil

--- Lane model: each lane owns left/middle/right/full zones in its own scene slice.
--- Lanes stack downward from a fixed origin (not from the live camera / output view).
local lanes = {}
local current_lane_index = 1
local lane_origin = nil -- { x, y } fixed at startup
local lane_size = nil -- { w, h } panel size for each lane
--- Vertical gap between lanes so the next lane's help guide stays out of the previous view.
local LANE_GAP = 48

--- Enable connected DRM connectors as physical outputs with a full main view each.
local function preferred_mode(connector)
  for _, mode in ipairs(connector.modes or {}) do
    if mode.preferred then
      return mode
    end
  end
  return (connector.modes or {})[1]
end

local function enable_all_drm_outputs(devices)
  local connectors = {}
  for _, device in ipairs(devices or {}) do
    for _, connector in ipairs(device.connectors or {}) do
      if connector.connected then
        table.insert(connectors, connector)
      end
    end
  end
  table.sort(connectors, function(a, b)
    return a.name < b.name
  end)

  local configs = {}
  local enabled = {}
  for _, connector in ipairs(connectors) do
    local mode = preferred_mode(connector)
    table.insert(configs, {
      name = connector.name,
      enabled = true,
      mode = mode and mode.name or nil,
    })
    enabled[connector.name] = { connector = connector, mode = mode }
  end

  if #configs > 0 then
    lum.set_output_configs(configs)
  end

  for _, output in ipairs(lum.get_outputs()) do
    if not output.virtual and not enabled[output.name] then
      lum.remove_output(output.name)
    end
  end

  local existing = {}
  for _, output in ipairs(lum.get_outputs()) do
    existing[output.name] = true
  end

  local x = 0
  local primary_name = connectors[1] and connectors[1].name
  for _, connector in ipairs(connectors) do
    local mode = enabled[connector.name].mode
    local width = mode and mode.width or 0
    local height = mode and mode.height or 0
    local refresh_mhz = mode and (mode.refresh_hz * 1000) or 60000

    if width > 0 and height > 0 then
      if not existing[connector.name] then
        lum.add_output({
          name = connector.name,
          description = connector.connector_type .. " " .. connector.name,
          width = width,
          height = height,
          refresh_mhz = refresh_mhz,
          mm_width = connector.mm_width,
          mm_height = connector.mm_height,
          scale = 1,
          virtual = false,
        })
      end
      -- View source origin places this panel in global compositor space.
      lum.add_view(connector.name, {
        name = "main",
        source = { x = x, y = 0, width = width, height = height },
        dest = { x = 0, y = 0, width = width, height = height },
      })
      if connector.name == primary_name then
        main_view = { x = x, y = 0, w = width, h = height }
      end
    end
    x = x + width
  end
end

--- Apps that include CSD/titlebar height in their size even when decorations are hidden.
local DECORATION_HEIGHT_EXTRA = 25

local function primary_output()
  for _, output in ipairs(lum.get_outputs()) do
    if not output.virtual then
      return output
    end
  end
  return lum.get_outputs()[1]
end

--- Tracked camera state is declared at file scope (main_view).

local function push_main_view()
  local output = primary_output()
  if not output or not main_view then
    return
  end
  lum.add_view(output.name, {
    name = "main",
    source = {
      x = math.floor(main_view.x + 0.5),
      y = math.floor(main_view.y + 0.5),
      width = math.max(1, math.floor(main_view.w + 0.5)),
      height = math.max(1, math.floor(main_view.h + 0.5)),
    },
    dest = { x = 0, y = 0, width = output.width, height = output.height },
  })
end

local function copy_rect(rect)
  return { x = rect.x, y = rect.y, w = rect.w, h = rect.h }
end

local function current_lane()
  if #lanes == 0 then
    return nil
  end
  return lanes[current_lane_index]
end

local function lane_zone_name(lane, zone)
  return "lane_" .. lane.index .. "_" .. zone
end

local function lane_name_label(name)
  local cleaned = tostring(name):gsub("[^%w]", "_")
  if cleaned == "" then
    cleaned = "lane"
  end
  return cleaned
end

local function reset_main_view_to_current_lane()
  local lane = current_lane()
  if not lane then
    return
  end
  main_view = copy_rect(lane.view)
  push_main_view()
end

--- logo held: view-move mode — middle-drag pans the main camera; scroll zooms toward cursor.
local BTN_MIDDLE = 0x112
local view_move_mode = false
local middle_dragging = false
--- Super_L / Super_R refcount so releasing one key does not end the mode early.
local super_held = 0

local function pan_main_view(dx, dy)
  local output = primary_output()
  if not output or not main_view then
    return
  end
  -- Map screen deltas into source space (grab-the-content: drag right → source moves left).
  local scale_x = main_view.w / output.width
  local scale_y = main_view.h / output.height
  main_view.x = main_view.x - dx * scale_x
  main_view.y = main_view.y - dy * scale_y
  push_main_view()
end

local function zoom_main_view(cursor_x, cursor_y, value)
  local output = primary_output()
  if not output or not main_view or value == 0 then
    return
  end
  -- Scroll up / negative → zoom in (smaller source); scroll down → zoom out.
  local factor = value < 0 and (1 / 1.1) or 1.1
  local min_w = math.max(32, math.floor(output.width * 0.05))
  local min_h = math.max(32, math.floor(output.height * 0.05))

  -- Scene point currently under the cursor (monitor → source).
  local fx = cursor_x / output.width
  local fy = cursor_y / output.height
  local focus_x = main_view.x + fx * main_view.w
  local focus_y = main_view.y + fy * main_view.h

  local new_w = math.max(min_w, main_view.w * factor)
  local new_h = math.max(min_h, main_view.h * factor)
  -- Keep aspect ratio locked to the panel.
  local aspect = output.width / output.height
  if new_w / new_h > aspect then
    new_h = new_w / aspect
  else
    new_w = new_h * aspect
  end

  -- Keep that scene point under the cursor after the scale (Miro-style).
  main_view.w = new_w
  main_view.h = new_h
  main_view.x = focus_x - fx * new_w
  main_view.y = focus_y - fy * new_h
  push_main_view()
end

-- Listen only while logo is held; consume so clients don't see the drag/scroll.
lum.on_cursor_click({
  mods = "logo",
  consume = true,
  callback = function(_x, _y, button, pressed)
    if not view_move_mode or button ~= BTN_MIDDLE then
      return
    end
    middle_dragging = pressed
  end,
})
lum.on_cursor_move({
  mods = "logo",
  consume = true,
  callback = function(_x, _y, dx, dy)
    if view_move_mode and middle_dragging then
      pan_main_view(dx, dy)
    end
  end,
})
lum.on_cursor_scroll({
  mods = "logo",
  consume = true,
  callback = function(x, y, axis, value)
    if view_move_mode and axis == 0 then
      zoom_main_view(x, y, value)
    end
  end,
})

local function enter_view_move_mode()
  super_held = super_held + 1
  if super_held ~= 1 then
    return
  end
  view_move_mode = true
  if not main_view then
    local output = primary_output()
    if not output then
      return
    end
    main_view = { x = output.x, y = output.y, w = output.width, h = output.height }
    push_main_view()
  end
end

local function leave_view_move_mode()
  super_held = math.max(0, super_held - 1)
  if super_held ~= 0 then
    return
  end
  view_move_mode = false
  middle_dragging = false
end

local function define_lane_zones(lane, output, is_current)
  if not output then
    return
  end
  local w, h = output.width, output.height
  local ox, oy = lane.view.x, lane.view.y
  local left_w = math.floor(w * 0.25)
  local mid_w = math.floor(w * 0.5)
  local right_w = w - left_w - mid_w

  local function zone(name, x, width, height_extra, is_default)
    lum.add_zone({
      name = lane_zone_name(lane, name),
      x = ox + x,
      y = oy,
      default = is_default or false,
      composition = "free",
      default_width = width,
      default_height = h + height_extra,
    })
  end

  -- Native Wayland clients: exact panel height.
  zone("left", 0, left_w, 0, false)
  zone("middle", left_w, mid_w, 0, is_current == true)
  zone("right", left_w + mid_w, right_w, 0, false)
  zone("full", 0, w, 0, false)
  -- CSD/X11 clients that include titlebar height in their size (e.g. Spotify).
  zone("left_decorated", 0, left_w, DECORATION_HEIGHT_EXTRA, false)
  zone("middle_decorated", left_w, mid_w, DECORATION_HEIGHT_EXTRA, false)
  zone("right_decorated", left_w + mid_w, right_w, DECORATION_HEIGHT_EXTRA, false)
  zone("full_decorated", 0, w, DECORATION_HEIGHT_EXTRA, false)
end

--- Keep compositor default zone on the currently selected lane's middle.
local function refresh_default_zone()
  local output = primary_output()
  if not output then
    return
  end
  for i, lane in ipairs(lanes) do
    define_lane_zones(lane, output, i == current_lane_index)
  end
end

local function upsert_lane_help_guide(lane)
  -- Sit just above the lane top edge so the label is off-screen until you pan up.
  local y = lane.view.y - 2
  pcall(lum.remove_guide, lane.guide_name)
  lum.add_guide({
    name = lane.guide_name,
    kind = "line",
    layer = "above",
    x1 = lane.view.x,
    y1 = y,
    x2 = lane.view.x + lane.view.w,
    y2 = y,
    color = { r = 160, g = 200, b = 255, a = 180 },
    stroke = 2,
    label = lane_name_label(lane.name),
  })
end

local function ensure_lane_grid(output)
  if lane_origin and lane_size then
    return
  end
  -- Freeze the grid to the initial camera/panel placement. Do not use live
  -- output.x/y later: get_outputs() reports the current view source origin,
  -- which moves when panning/zooming.
  local ox, oy = 0, 0
  local w, h = output.width, output.height
  if main_view then
    ox, oy = main_view.x, main_view.y
    w, h = main_view.w, main_view.h
  end
  lane_origin = { x = ox, y = oy }
  lane_size = { w = w, h = h }
end

local function lane_rect_for_index(lane_index)
  return {
    x = lane_origin.x,
    y = lane_origin.y + ((lane_index - 1) * (lane_size.h + LANE_GAP)),
    w = lane_size.w,
    h = lane_size.h,
  }
end

local function add_lane(name, make_current)
  local output = primary_output()
  if not output then
    return nil
  end
  ensure_lane_grid(output)

  local lane_index = #lanes + 1
  local lane = {
    index = lane_index,
    name = name,
    is_default = lane_index == 1,
    view = lane_rect_for_index(lane_index),
    guide_name = "lane_help_" .. lane_index,
  }

  table.insert(lanes, lane)
  -- Zones for the new lane; default flag is finalized below via refresh.
  define_lane_zones(lane, output, false)
  upsert_lane_help_guide(lane)

  if make_current then
    current_lane_index = lane_index
    reset_main_view_to_current_lane()
  end
  refresh_default_zone()

  return lane
end

local function window_on_lane(window, lane)
  if not lane then
    return false
  end
  local zone = window.zone
  if type(zone) ~= "string" or zone == "" then
    return false
  end
  return zone:match("^lane_" .. lane.index .. "_") ~= nil
end

local function windows_on_lane(lane)
  local matched = {}
  if not lane then
    return matched
  end
  for _, window in ipairs(lum.get_windows()) do
    if window_on_lane(window, lane) then
      table.insert(matched, window)
    end
  end
  return matched
end

local function focus_top_window_on_lane(lane)
  local top = nil
  for _, window in ipairs(windows_on_lane(lane)) do
    if not top or (window.stack or 0) > (top.stack or 0) then
      top = window
    end
  end
  if top then
    lum.focus_window({ id = top.id, raise = true })
  end
end

local function close_windows_on_lane(lane)
  for _, window in ipairs(windows_on_lane(lane)) do
    pcall(lum.close_window, { id = window.id })
  end
end

local function switch_lane(delta)
  local count = #lanes
  if count == 0 then
    return
  end
  current_lane_index = ((current_lane_index - 1 + delta) % count) + 1
  reset_main_view_to_current_lane()
  refresh_default_zone()
  focus_top_window_on_lane(current_lane())
end

local add_default_window_rules
local lane_ui_feedback_guide = "lane_ui_feedback"

local function delete_current_lane()
  local lane = current_lane()
  if not lane or lane.is_default then
    return
  end

  close_windows_on_lane(lane)

  for _, zone_name in ipairs({
    "left",
    "middle",
    "right",
    "full",
    "left_decorated",
    "middle_decorated",
    "right_decorated",
    "full_decorated",
  }) do
    pcall(lum.remove_zone, lane_zone_name(lane, zone_name))
  end
  pcall(lum.remove_guide, lane.guide_name)

  table.remove(lanes, current_lane_index)
  if current_lane_index > #lanes then
    current_lane_index = #lanes
  end
  if current_lane_index < 1 then
    current_lane_index = 1
  end

  reset_main_view_to_current_lane()
  refresh_default_zone()
  add_default_window_rules()
  focus_top_window_on_lane(current_lane())
end

add_default_window_rules = function()
  local lane = current_lane()
  if not lane then
    return
  end

  lum.clear_window_rules()
  lum.add_window_rule({
    app_id = "io.github.Qalculate.qalculate-qt",
    zone = lane_zone_name(lane, "right"),
  })
  lum.add_window_rule({ app_id = "brave-browser", zone = lane_zone_name(lane, "middle") })
  lum.add_window_rule({ app_id = "discord", zone = lane_zone_name(lane, "left") })
  lum.add_window_rule({ app_id = "org.wezfurlong.wezterm", zone = lane_zone_name(lane, "middle") })
  lum.add_window_rule({ app_id = "thunderbird", zone = lane_zone_name(lane, "middle") })
  lum.add_window_rule({ app_id = "Spotify", zone = lane_zone_name(lane, "right_decorated") })
end

local function show_lane_ui_feedback(label)
  pcall(lum.remove_guide, lane_ui_feedback_guide)
  local lane = current_lane()
  if not lane then
    return
  end
  lum.add_guide({
    name = lane_ui_feedback_guide,
    kind = "line",
    layer = "above",
    x1 = lane.view.x,
    y1 = lane.view.y - 2,
    x2 = lane.view.x + lane.view.w,
    y2 = lane.view.y - 2,
    color = { r = 255, g = 120, b = 120, a = 220 },
    stroke = 2,
    label = lane_name_label(label),
  })
end

local function rename_lane(lane, name)
  if not lane then
    return
  end
  lane.name = name
  upsert_lane_help_guide(lane)
end

--- Place the rename form in the current lane view with an explicit size.
--- (eframe often fails to set size when left to large free-zone defaults.)
local function prepare_lane_form_placement(lane)
  reset_main_view_to_current_lane()
  lum.clear_window_rules()
  lum.add_window_rule({
    app_id = "lumalla-ui",
    x = lane.view.x + math.floor(lane.view.w * 0.3),
    y = lane.view.y + math.floor(lane.view.h * 0.25),
    width = 420,
    height = 280,
  })
end

local function show_lane_creation_ui()
  -- Always create the lane first so logo+n has an immediate visible effect even
  -- when lumalla-ui fails to map a usable window (common: "Failed to set window size").
  local lane = add_lane("lane" .. tostring(#lanes + 1), true)
  if not lane then
    return
  end
  add_default_window_rules()
  prepare_lane_form_placement(lane)

  local opened = pcall(function()
    lum.ui({
      title = "Name lane",
      fields = {
        {
          id = "name",
          type = "text",
          label = "Lane name",
          placeholder = lane.name,
          default = lane.name,
          focus = true,
        },
      },
      actions = {
        { id = "cancel", label = "Keep name" },
        { id = "ok", label = "Rename", primary = true, submit = true },
      },
      on_submit = function(values, action)
        add_default_window_rules()
        if action ~= "ok" then
          return
        end
        local name = values.name
        if type(name) ~= "string" then
          return
        end
        name = name:gsub("^%s+", ""):gsub("%s+$", "")
        if name == "" then
          return
        end
        rename_lane(lane, name)
        pcall(lum.remove_guide, lane_ui_feedback_guide)
      end,
      on_cancel = function()
        add_default_window_rules()
      end,
    })
  end)

  if not opened then
    show_lane_ui_feedback("named_" .. lane.name)
  end
end

lum.on_startup(function()
  enable_all_drm_outputs(lum.get_drm_devices())
  lanes = {}
  current_lane_index = 1
  lane_origin = nil
  lane_size = nil
  add_lane("main", true)
  add_default_window_rules()

  -- Push WAYLAND_DISPLAY (injected by lum.spawn) into the systemd user session
  -- so xdg-desktop-portal / portal-gnome can reach the compositor.
  lum.spawn({
    command = "dbus-update-activation-environment",
    args = {
      "--systemd",
      "WAYLAND_DISPLAY",
      "XDG_CURRENT_DESKTOP",
      "XDG_SESSION_TYPE",
      "XDG_SESSION_DESKTOP",
    },
  })

  lum.spawn({ command = "xwayland-satellite", args = { ":1" } })
  lum.sleep(0.1)
  -- Discord/Spotify (and other Ozone apps) still need an X11 DISPLAY for the
  -- main window to leave the splash; satellite provides :1. Applied to every
  -- subsequent lum.spawn.
  lum.set_extra_env("DISPLAY", ":1")
  lum.spawn({
    command = "dbus-update-activation-environment",
    args = { "--systemd", "DISPLAY" },
  })
  lum.spawn({ command = "brave" })
  lum.spawn({ command = "discord" })
  lum.spawn({ command = "spotify" })
  lum.spawn({ command = "wezterm", args = { "start", "--always-new-process" } })
end)

lum.set_xkb({
  layout = "de",
})

--- Hold logo to enter view-move mode; release to leave.
for _, key in ipairs({ "Super_L", "Super_R" }) do
  lum.map_key({
    key = key,
    on = "down",
    consume = false,
    callback = enter_view_move_mode,
  })
  lum.map_key({
    key = key,
    on = "up",
    consume = false,
    callback = leave_view_move_mode,
  })
end

--- logo+r: reset the view to the currently selected lane.
lum.map_key({
  key = "r",
  mods = "logo",
  callback = reset_main_view_to_current_lane,
})

lum.map_key({
  key = "m",
  mods = "logo",
  callback = function()
    lum.set_window({ width = 1200, height = 800 })
  end,
})

local function cycle_windows(backward)
  local windows = lum.get_windows()
  if #windows == 0 then
    return
  end

  local focused = lum.get_focused_window()
  local index = 1
  for i, window in ipairs(windows) do
    if window.id == focused then
      index = i
      break
    end
  end

  local next_index
  if backward then
    next_index = index == 1 and #windows or index - 1
  else
    next_index = index % #windows + 1
  end

  lum.focus_window({ id = windows[next_index].id, raise = true })
end

lum.map_key({
  key = "Tab",
  mods = "alt",
  on = "down",
  consume = true,
  callback = function()
    cycle_windows(false)
  end,
})

lum.map_key({
  key = "Tab",
  mods = "alt|shift",
  on = "down",
  consume = true,
  callback = function()
    cycle_windows(true)
  end,
})

--- Focus a window by app_id on the current lane, or spawn it if none is open there.
local function window_on_current_lane(window)
  return window_on_lane(window, current_lane())
end

local function focus_or_spawn(app_id, spawn)
  for _, window in ipairs(lum.get_windows()) do
    if window.app_id == app_id and window_on_current_lane(window) then
      lum.focus_window({ id = window.id, raise = true })
      return
    end
  end
  lum.spawn(spawn)
end

lum.map_key({
  key = "1",
  mods = "logo",
  callback = function()
    focus_or_spawn("brave-browser", {
      command = "brave",
    })
  end,
})

lum.map_key({
  key = "2",
  mods = "logo",
  callback = function()
    focus_or_spawn("discord", {
      command = "discord",
    })
  end,
})

lum.map_key({
  key = "3",
  mods = "logo",
  callback = function()
    focus_or_spawn("org.wezfurlong.wezterm", {
      command = "wezterm",
      args = { "start", "--always-new-process" },
    })
  end,
})

lum.map_key({
  key = "4",
  mods = "logo",
  callback = function()
    focus_or_spawn("thunderbird", {
      command = "thunderbird",
    })
  end,
})

lum.map_key({
  key = "5",
  mods = "logo",
  callback = function()
    focus_or_spawn("Spotify", {
      command = "spotify",
    })
  end,
})

--- Move the focused window into a named zone on the current lane.
local function move_to_zone(zone_name)
  local lane = current_lane()
  if not lane then
    return
  end
  lum.add_window_to_zone({ zone = lane_zone_name(lane, zone_name) })
end

--- logo+arrows: left / middle / right / full (on current lane)
lum.map_key({
  key = "Left",
  mods = "logo",
  callback = function()
    move_to_zone("left")
  end,
})
lum.map_key({
  key = "Up",
  mods = "logo",
  callback = function()
    move_to_zone("middle")
  end,
})
lum.map_key({
  key = "Right",
  mods = "logo",
  callback = function()
    move_to_zone("right")
  end,
})
lum.map_key({
  key = "Down",
  mods = "logo",
  callback = function()
    move_to_zone("full")
  end,
})

--- logo+shift+arrows: same slices with decoration height offset
lum.map_key({
  key = "Left",
  mods = "logo|shift",
  callback = function()
    move_to_zone("left_decorated")
  end,
})
lum.map_key({
  key = "Up",
  mods = "logo|shift",
  callback = function()
    move_to_zone("middle_decorated")
  end,
})
lum.map_key({
  key = "Right",
  mods = "logo|shift",
  callback = function()
    move_to_zone("right_decorated")
  end,
})
lum.map_key({
  key = "Down",
  mods = "logo|shift",
  callback = function()
    move_to_zone("full_decorated")
  end,
})

--- logo+j / logo+k: switch selected lane (and jump view to it).
lum.map_key({
  key = "j",
  mods = "logo",
  callback = function()
    switch_lane(1)
    add_default_window_rules()
  end,
})
lum.map_key({
  key = "k",
  mods = "logo",
  callback = function()
    switch_lane(-1)
    add_default_window_rules()
  end,
})

--- logo+n: prompt for a lane name and create it.
lum.map_key({
  key = "n",
  mods = "logo",
  callback = show_lane_creation_ui,
})

--- logo+x: delete current lane (default lane is protected).
lum.map_key({
  key = "x",
  mods = "logo",
  callback = delete_current_lane,
})

lum.map_key({
  key = "XF86AudioRaiseVolume",
  callback = function()
    lum.spawn({
      command = "wpctl",
      args = { "set-volume", "@DEFAULT_AUDIO_SINK@", "5%+" },
    })
  end,
})

lum.map_key({
  key = "XF86AudioLowerVolume",
  callback = function()
    lum.spawn({
      command = "wpctl",
      args = { "set-volume", "@DEFAULT_AUDIO_SINK@", "5%-" },
    })
  end,
})