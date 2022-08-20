local status_ok, nvim_tree = pcall(require, "nvim-tree")
if not status_ok then
  return
end

nvim_tree.setup {
  disable_netrw = true,
  update_cwd = true,
  diagnostics = {
    enable = true,
    icons = {
      hint = "",
      info = "",
      warning = "",
      error = "",
    },
  },
  update_focused_file = {
    enable = true,
    update_cwd = true,
  },
  view = {
    adaptive_size = true,
    mappings = {
      list = {
        { key = "v", action = "vsplit" },
      },
    },
  },
  renderer = {
    highlight_git = true,
  },
  actions = {
    open_file = {
      quit_on_open = true,
    },
  },
}
