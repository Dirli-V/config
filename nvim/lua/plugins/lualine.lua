return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  opts = function()
    local icons = require("lazyconfig").icons

    return {
      options = {
        theme = "auto",
        globalstatus = true,
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch" },
        lualine_c = {
          {
            "diagnostics",
            symbols = {
              error = icons.diagnostics.Error,
              warn = icons.diagnostics.Warn,
              info = icons.diagnostics.Info,
              hint = icons.diagnostics.Hint,
            },
          },
          { "filename", path = 1, symbols = { modified = "  ", readonly = " 🔒 ", unnamed = "" } },
        },
        lualine_x = {
          {
            "diff",
            symbols = {
              added = icons.git.added,
              modified = icons.git.modified,
              removed = icons.git.removed,
            },
          },
        },
        lualine_y = {
          { "filetype", separator = "", padding = { left = 1, right = 0 } },
          { "encoding", separator = "", padding = { left = 1, right = 0 } },
          { "fileformat", padding = { left = 1, right = 1 } },
        },
        lualine_z = {
          { "progress", separator = "", padding = { left = 1, right = 0 } },
          { "location", padding = { left = 0, right = 1 } },
        },
      },
      extensions = { "neo-tree", "lazy" },
    }
  end,
}
