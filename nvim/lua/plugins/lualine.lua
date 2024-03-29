return {
  "nvim-lualine/lualine.nvim",
  dependencies = {
    "arkav/lualine-lsp-progress",
  },
  event = "VeryLazy",
  opts = function()
    local icons = require("config.icons")
    local custom_fname = require("lualine.components.filename"):extend()
    local highlight = require("lualine.highlight")
    local default_status_colors = {
      saved = "#B1B9D4",
      modified = "#F9E2AF",
      new = "#A6E3A1",
      readonly = "#F38BA8",
    }

    function custom_fname:init(options)
      custom_fname.super.init(self, options)
      self.status_colors = {
        saved = highlight.create_component_highlight_group(
          { fg = default_status_colors.saved },
          "filename_status_saved",
          self.options
        ),
        modified = highlight.create_component_highlight_group(
          { fg = default_status_colors.modified },
          "filename_status_modified",
          self.options
        ),
        new = highlight.create_component_highlight_group(
          { fg = default_status_colors.modified },
          "filename_status_new",
          self.options
        ),
        readonly = highlight.create_component_highlight_group(
          { fg = default_status_colors.modified },
          "filename_status_readonly",
          self.options
        ),
      }
      if self.options.color == nil then
        self.options.color = ""
      end
    end

    function custom_fname:update_status()
      local filename = custom_fname.super.update_status(self)
      return highlight.component_format_highlight(
        vim.bo.modified and self.status_colors.modified
          or vim.bo.readonly and self.status_colors.readonly
          or self.status_colors.saved
      ) .. filename
    end

    local tab_status = require("lualine.component"):extend()
    function tab_status:init(options)
      tab_status.super.init(self, options)
      self.tab_highlights = {
        open_tab_highlight = highlight.create_component_highlight_group(
          { fg = "#89B4FA", bg = "#45475A" },
          "currently_open_tab",
          options
        ),
        other_tab_highlight = highlight.create_component_highlight_group({ fg = "#CDD6F4" }, "other_tab", options),
      }
    end

    function tab_status:update_status()
      local tabs = vim.api.nvim_list_tabpages()
      if #tabs <= 1 then
        return ""
      end

      local result = highlight.component_format_highlight(self.tab_highlights.other_tab_highlight)
      local current_tab = vim.api.nvim_get_current_tabpage()
      for _, tab in ipairs(tabs) do
        if tab == current_tab then
          result = result
            .. highlight.component_format_highlight(self.tab_highlights.open_tab_highlight)
            .. tab
            .. highlight.component_format_highlight(self.tab_highlights.other_tab_highlight)
            .. " "
        else
          result = result .. tab .. " "
        end
      end
      return result
    end

    return {
      options = {
        theme = "auto",
        globalstatus = true,
        component_separators = "",
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = {
          {
            "branch",
            fmt = function(str)
              if string.len(str) > 35 then
                return string.sub(str, 1, 30) .. "..."
              else
                return str
              end
            end,
          },
        },
        lualine_c = {
          { custom_fname, path = 1, symbols = { modified = "", readonly = "", unnamed = "" } },
          {
            "diagnostics",
            symbols = {
              error = icons.diagnostics.Error,
              warn = icons.diagnostics.Warn,
              info = icons.diagnostics.Info,
              hint = icons.diagnostics.Hint,
            },
          },
          {
            "lsp_progress",
            display_components = { "spinner" },
            spinner_symbols = { "⣷", "⣯", "⣟", "⡿", "⢿", "⣻", "⣽", "⣾" },
            timer = { progress_enddelay = 0, spinner = 1000 },
          },
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
          {
            tab_status,
            padding = { left = 0, right = 0 },
          },
        },
        lualine_y = {
          { "filetype", separator = "", padding = { left = 1, right = 0 } },
          function()
            if vim.bo.expandtab then
              return "Spc:" .. vim.bo.tabstop
            else
              return "Tab:" .. vim.bo.tabstop
            end
          end,
          { "encoding", separator = "", padding = { left = 0, right = 0 } },
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
