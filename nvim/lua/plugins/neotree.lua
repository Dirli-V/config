return {
  "nvim-neo-tree/neo-tree.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
  },
  cmd = "Neotree",
  keys = {
    {
      "<leader>E",
      function()
        require("neo-tree.command").execute({ toggle = true, dir = require("helpers").get_root(), reveal = true })
      end,
      desc = "Explorer NeoTree (root dir)",
    },
    {
      "<leader>e",
      function()
        require("neo-tree.command").execute({ toggle = true, dir = vim.loop.cwd(), reveal = true })
      end,
      desc = "Explorer NeoTree (cwd)",
    },
    {
      "<leader>cs",
      "<cmd>Neotree document_symbols<cr>",
      desc = "Symbol tree",
    },
  },
  init = function()
    vim.g.neo_tree_remove_legacy_commands = 1
    if vim.fn.argc() == 1 then
      ---@diagnostic disable-next-line: param-type-mismatch
      local stat = vim.loop.fs_stat(vim.fn.argv(0))
      if stat and stat.type == "directory" then
        require("neo-tree")
      end
    end
  end,
  opts = {
    default_component_configs = {
      indent = {
        with_expanders = true, -- if nil and file nesting is enabled, will enable expanders
        expander_collapsed = "",
        expander_expanded = "",
        expander_highlight = "NeoTreeExpander",
      },
    },
    event_handlers = {
      {
        event = "file_opened",
        handler = function()
          --auto close
          require("neo-tree").close_all()
        end,
      },
    },
    filesystem = {
      filtered_items = {
        visible = true,
        hide_dotfiles = false,
      },
      bind_to_cwd = false,
      follow_current_file = {
        enable = true,
      },
      use_libuv_file_watcher = true,
    },
    sources = {
      "filesystem",
      "document_symbols",
    },
    window = {
      mappings = {
        ["<space>"] = "none",
      },
      width = "fit_content",
    },
  },
}
