-- Ember dark — https://github.com/ember-theme/alacritty/blob/main/themes/ember.toml
local ansi = {
  "#1c1b19",
  "#e08060",
  "#8a9868",
  "#c8b468",
  "#7890a0",
  "#b07878",
  "#80a090",
  "#d8d0c0",
}

return {
  foreground = "#d8d0c0",
  background = "#1c1b19",
  cursor_bg = "#e08060",
  cursor_fg = "#1c1b19",
  cursor_border = "#e08060",
  selection_bg = "#3e3c38",
  selection_fg = "#d8d0c0",
  split = "#3e3c38",
  scrollbar_thumb = "#585550",
  ansi = ansi,
  brights = ansi,
  tab_bar = {
    inactive_tab_edge = "#3e3c38",
    active_tab = {
      bg_color = "#e08060",
      fg_color = "#1c1b19",
    },
    inactive_tab = {
      bg_color = "#252422",
      fg_color = "#908a7e",
    },
    new_tab = {
      bg_color = "#252422",
      fg_color = "#e08060",
    },
  },
  indexed = {
    [16] = "#c09058",
    [17] = "#988090",
  },
}
