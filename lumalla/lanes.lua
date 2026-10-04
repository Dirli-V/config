--- Lane model: each lane owns left/middle/right/full zones in its own scene slice.
--- Lanes stack downward from a fixed origin (not from the live camera / output view).
---
--- Usage from init.lua:
---   local lanes = dofile(config_dir .. "/lanes.lua")({
---     primary_output = primary_output,
---     get_main_view = function() return main_view end,
---     set_main_view = function(v) main_view = v end,
---     push_main_view = push_main_view,
---   })

local lum = require("lumalla")

--- Apps that include CSD/titlebar height in their size even when decorations are hidden.
local DECORATION_HEIGHT_EXTRA = 25
--- Reserve space under DankMaterialShell's top bar (exclusive zone ≈ thickness + spacing).
local TOP_BAR_HEIGHT = 40
--- Vertical gap between lanes so the next lane's help guide stays out of the previous view.
local LANE_GAP = 48

return function(deps)
  local primary_output = deps.primary_output
  local get_main_view = deps.get_main_view
  local set_main_view = deps.set_main_view
  local push_main_view = deps.push_main_view

  local lanes = {}
  local current_lane_index = 1
  local lane_origin = nil -- { x, y } fixed at startup
  local lane_size = nil -- { w, h } panel size for each lane
  local lane_ui_feedback_guide = "lane_ui_feedback"
  local add_default_window_rules

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
    set_main_view(copy_rect(lane.view))
    push_main_view()
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
    local content_h = math.max(1, h - TOP_BAR_HEIGHT)

    local function zone(name, x, width, height_extra, is_default)
      lum.add_zone({
        name = lane_zone_name(lane, name),
        x = ox + x,
        y = oy + TOP_BAR_HEIGHT,
        default = is_default or false,
        composition = "free",
        default_width = width,
        default_height = content_h + height_extra,
      })
    end

    -- Native Wayland clients: panel height minus top bar.
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
    local main_view = get_main_view()
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

  local M = {}

  function M.init()
    lanes = {}
    current_lane_index = 1
    lane_origin = nil
    lane_size = nil
    add_lane("main", true)
    add_default_window_rules()
  end

  function M.reset_view()
    reset_main_view_to_current_lane()
  end

  function M.switch(delta)
    switch_lane(delta)
    add_default_window_rules()
  end

  function M.show_creation_ui()
    show_lane_creation_ui()
  end

  function M.delete_current()
    delete_current_lane()
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

  function M.current()
    return current_lane()
  end

  -- Opt into REPL when the host supports exports (`cfg.lanes.switch(1)`, etc.).
  if type(lum.export) == "function" then
    lum.export("lanes", M)
  elseif type(lum.exports) == "table" then
    lum.exports.lanes = M
  end

  return M
end
