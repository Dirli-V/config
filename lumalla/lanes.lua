--- Lumalla lanes plugin: stacked scene lanes with per-lane zones.
---
--- Usage from init.lua:
---   local lanes = dofile(config_dir .. "/lanes.lua")
---   lanes.config({
---     window_rules = {
---       { app_id = "brave-browser", zone = "middle" },
---     },
---   })
---
--- Exported as `cfg.lanes` via lum.export for the REPL.

local lum = require("lumalla")

local DEFAULTS = {
  zone_prefix = "lane",
  top_bar_height = 40,
  lane_gap = 48,
  decoration_height_extra = 25,
  default_lane_name = "main",
  decorated_zones = true,
  zones = {
    { name = "left", width = 0.25 },
    { name = "middle", width = 0.5, default = true },
    { name = "right", width = 0.25 },
    { name = "full", width = 1.0 },
  },
  window_rules = {},
}

local function copy_zones(zones)
  local copy = {}
  for i, zone in ipairs(zones) do
    copy[i] = {
      name = zone.name,
      width = zone.width,
      default = zone.default,
    }
  end
  return copy
end

local function copy_rules(rules)
  local copy = {}
  for i, rule in ipairs(rules) do
    copy[i] = {
      app_id = rule.app_id,
      title = rule.title,
      zone = rule.zone,
      x = rule.x,
      y = rule.y,
      width = rule.width,
      height = rule.height,
    }
  end
  return copy
end

local opts = {
  zone_prefix = DEFAULTS.zone_prefix,
  top_bar_height = DEFAULTS.top_bar_height,
  lane_gap = DEFAULTS.lane_gap,
  decoration_height_extra = DEFAULTS.decoration_height_extra,
  default_lane_name = DEFAULTS.default_lane_name,
  decorated_zones = DEFAULTS.decorated_zones,
  zones = copy_zones(DEFAULTS.zones),
  window_rules = copy_rules(DEFAULTS.window_rules),
}

local lanes = {}
local current_lane_index = 1
local lane_origin = nil -- { x, y } fixed at first bootstrap
local lane_size = nil -- { w, h } panel size for each lane
local main_view = nil -- camera source rect owned by this plugin
local lane_ui_feedback_guide = "lane_ui_feedback"
local connector_hook_id = nil
local bootstrapped = false
local apply_window_rules

local M = {}

local function copy_rect(rect)
  return { x = rect.x, y = rect.y, w = rect.w, h = rect.h }
end

local function primary_output()
  for _, output in ipairs(lum.get_outputs()) do
    if not output.virtual then
      return output
    end
  end
  return lum.get_outputs()[1]
end

local function current_lane()
  if #lanes == 0 then
    return nil
  end
  return lanes[current_lane_index]
end

local function lane_zone_name(lane, zone)
  return opts.zone_prefix .. "_" .. lane.index .. "_" .. zone
end

local function zone_suffixes()
  local names = {}
  for _, zone in ipairs(opts.zones) do
    table.insert(names, zone.name)
    if opts.decorated_zones then
      table.insert(names, zone.name .. "_decorated")
    end
  end
  return names
end

local function lane_name_label(name)
  local cleaned = tostring(name):gsub("[^%w]", "_")
  if cleaned == "" then
    cleaned = "lane"
  end
  return cleaned
end

local function push_view()
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

local function reset_main_view_to_current_lane()
  local lane = current_lane()
  if not lane then
    return
  end
  main_view = copy_rect(lane.view)
  push_view()
end

local function add_zone_pair(lane, zone_name, x, y, width, height, height_extra, is_default)
  lum.add_zone({
    name = lane_zone_name(lane, zone_name),
    x = x,
    y = y,
    default = is_default or false,
    composition = "free",
    default_width = width,
    default_height = height,
  })
  if opts.decorated_zones then
    lum.add_zone({
      name = lane_zone_name(lane, zone_name .. "_decorated"),
      x = x,
      y = y,
      default = false,
      composition = "free",
      default_width = width,
      default_height = height + height_extra,
    })
  end
end

local function define_lane_zones(lane, output, is_current)
  if not output then
    return
  end
  local w, h = output.width, output.height
  local ox, oy = lane.view.x, lane.view.y
  local content_h = math.max(1, h - opts.top_bar_height)
  local zone_y = oy + opts.top_bar_height

  local partial = {}
  local full = {}
  for _, zone in ipairs(opts.zones) do
    if (zone.width or 0) >= 1.0 then
      table.insert(full, zone)
    else
      table.insert(partial, zone)
    end
  end

  local cursor = 0
  for i, zone in ipairs(partial) do
    local width
    if i == #partial then
      width = math.max(1, w - cursor)
    else
      width = math.floor(w * zone.width)
    end
    local is_default = is_current == true and zone.default == true
    add_zone_pair(
      lane,
      zone.name,
      ox + cursor,
      zone_y,
      width,
      content_h,
      opts.decoration_height_extra,
      is_default
    )
    cursor = cursor + width
  end

  for _, zone in ipairs(full) do
    local is_default = is_current == true and zone.default == true
    add_zone_pair(
      lane,
      zone.name,
      ox,
      zone_y,
      w,
      content_h,
      opts.decoration_height_extra,
      is_default
    )
  end
end

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
  local ox, oy = 0, 0
  local w, h = output.width, output.height
  if main_view then
    ox, oy = main_view.x, main_view.y
    w, h = main_view.w, main_view.h
  else
    -- Prefer the primary output's current main-view source if the host set one.
    ox, oy = output.x or 0, output.y or 0
    main_view = { x = ox, y = oy, w = w, h = h }
  end
  lane_origin = { x = ox, y = oy }
  lane_size = { w = w, h = h }
end

local function lane_rect_for_index(lane_index)
  return {
    x = lane_origin.x,
    y = lane_origin.y + ((lane_index - 1) * (lane_size.h + opts.lane_gap)),
    w = lane_size.w,
    h = lane_size.h,
  }
end

local function window_on_lane(window, lane)
  if not lane then
    return false
  end
  local zone = window.zone
  if type(zone) ~= "string" or zone == "" then
    return false
  end
  local prefix = opts.zone_prefix .. "_" .. lane.index .. "_"
  return zone:sub(1, #prefix) == prefix
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

apply_window_rules = function()
  local lane = current_lane()
  if not lane then
    return
  end

  lum.clear_window_rules()
  for _, rule in ipairs(opts.window_rules) do
    local entry = {
      zone = lane_zone_name(lane, rule.zone),
    }
    if rule.app_id then
      entry.app_id = rule.app_id
    end
    if rule.title then
      entry.title = rule.title
    end
    if rule.x then
      entry.x = rule.x
    end
    if rule.y then
      entry.y = rule.y
    end
    if rule.width then
      entry.width = rule.width
    end
    if rule.height then
      entry.height = rule.height
    end
    lum.add_window_rule(entry)
  end
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
    guide_name = opts.zone_prefix .. "_help_" .. lane_index,
  }

  table.insert(lanes, lane)
  define_lane_zones(lane, output, false)
  upsert_lane_help_guide(lane)

  if make_current then
    current_lane_index = lane_index
    reset_main_view_to_current_lane()
  end
  refresh_default_zone()

  return lane
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

local function delete_current_lane()
  local lane = current_lane()
  if not lane or lane.is_default then
    return
  end

  close_windows_on_lane(lane)

  for _, zone_name in ipairs(zone_suffixes()) do
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
  apply_window_rules()
  focus_top_window_on_lane(current_lane())
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
  local lane = add_lane("lane" .. tostring(#lanes + 1), true)
  if not lane then
    return
  end
  apply_window_rules()
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
        apply_window_rules()
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
        apply_window_rules()
      end,
    })
  end)

  if not opened then
    show_lane_ui_feedback("named_" .. lane.name)
  end
end

local function bootstrap_from_outputs()
  local output = primary_output()
  if not output then
    return
  end

  if not bootstrapped then
    lanes = {}
    current_lane_index = 1
    lane_origin = nil
    lane_size = nil
    if not main_view then
      main_view = {
        x = output.x or 0,
        y = output.y or 0,
        w = output.width,
        h = output.height,
      }
    end
    add_lane(opts.default_lane_name, true)
    apply_window_rules()
    bootstrapped = true
    return
  end

  -- Hotplug / refresh: rebuild zones for the current grid.
  refresh_default_zone()
  apply_window_rules()
end

local function ensure_connector_hook()
  if connector_hook_id ~= nil then
    return
  end
  connector_hook_id = lum.on_connector_change(function(_devices)
    bootstrap_from_outputs()
  end)
end

function M.config(user_opts)
  user_opts = user_opts or {}

  if user_opts.zone_prefix ~= nil then
    opts.zone_prefix = user_opts.zone_prefix
  end
  if user_opts.top_bar_height ~= nil then
    opts.top_bar_height = user_opts.top_bar_height
  end
  if user_opts.lane_gap ~= nil then
    opts.lane_gap = user_opts.lane_gap
  end
  if user_opts.decoration_height_extra ~= nil then
    opts.decoration_height_extra = user_opts.decoration_height_extra
  end
  if user_opts.default_lane_name ~= nil then
    opts.default_lane_name = user_opts.default_lane_name
  end
  if user_opts.decorated_zones ~= nil then
    opts.decorated_zones = user_opts.decorated_zones
  end
  if user_opts.zones ~= nil then
    opts.zones = copy_zones(user_opts.zones)
  end
  if user_opts.window_rules ~= nil then
    opts.window_rules = copy_rules(user_opts.window_rules)
  end

  ensure_connector_hook()

  if bootstrapped then
    refresh_default_zone()
    apply_window_rules()
  end

  return M
end

function M.add(name, make_current)
  if make_current == nil then
    make_current = true
  end
  local lane = add_lane(name or ("lane" .. tostring(#lanes + 1)), make_current)
  if lane then
    apply_window_rules()
  end
  return lane
end

function M.switch(delta)
  switch_lane(delta)
  apply_window_rules()
end

function M.delete_current()
  delete_current_lane()
end

function M.show_creation_ui()
  show_lane_creation_ui()
end

function M.current()
  return current_lane()
end

function M.list()
  local out = {}
  for i, lane in ipairs(lanes) do
    out[i] = lane
  end
  return out
end

function M.move_to_zone(zone_name)
  local lane = current_lane()
  if not lane then
    return
  end
  lum.add_window_to_zone({ zone = lane_zone_name(lane, zone_name) })
end

function M.window_on_current(window)
  return window_on_lane(window, current_lane())
end

function M.zone_name(lane, zone)
  return lane_zone_name(lane, zone)
end

function M.get_view()
  if not main_view then
    return nil
  end
  return copy_rect(main_view)
end

function M.set_view(rect)
  if not rect then
    main_view = nil
    return
  end
  main_view = copy_rect(rect)
end

function M.push_view()
  push_view()
end

function M.reset_view()
  reset_main_view_to_current_lane()
end

function M.pan(dx, dy)
  local output = primary_output()
  if not output or not main_view then
    return
  end
  local scale_x = main_view.w / output.width
  local scale_y = main_view.h / output.height
  main_view.x = main_view.x - dx * scale_x
  main_view.y = main_view.y - dy * scale_y
  push_view()
end

function M.zoom(cursor_x, cursor_y, value)
  local output = primary_output()
  if not output or not main_view or value == 0 then
    return
  end
  local factor = value < 0 and (1 / 1.1) or 1.1
  local min_w = math.max(32, math.floor(output.width * 0.05))
  local min_h = math.max(32, math.floor(output.height * 0.05))

  local fx = cursor_x / output.width
  local fy = cursor_y / output.height
  local focus_x = main_view.x + fx * main_view.w
  local focus_y = main_view.y + fy * main_view.h

  local new_w = math.max(min_w, main_view.w * factor)
  local new_h = math.max(min_h, main_view.h * factor)
  local aspect = output.width / output.height
  if new_w / new_h > aspect then
    new_h = new_w / aspect
  else
    new_w = new_h * aspect
  end

  main_view.w = new_w
  main_view.h = new_h
  main_view.x = focus_x - fx * new_w
  main_view.y = focus_y - fy * new_h
  push_view()
end

-- Register defaults + connector hook on load; export for REPL.
ensure_connector_hook()

if type(lum.export) == "function" then
  lum.export("lanes", M)
elseif type(lum.exports) == "table" then
  lum.exports.lanes = M
end

return M
