return {
  "neovim/nvim-lspconfig",
  dependencies = { "simrat39/rust-tools.nvim" },
  init = function()
    local keys = require("lazyvim.plugins.lsp.keymaps").get()
    keys[#keys + 1] = { "<leader>j", vim.diagnostic.goto_next }
    keys[#keys + 1] = { "<leader>k", vim.diagnostic.goto_prev }
  end,
  opts = {
    diagnostics = {
      update_in_insert = true,
    },
    servers = {
      jsonls = {
        mason = false,
      },
      lua_ls = {
        mason = false,
      },
      ltex = {
        mason = false,
      },
      rust_analyzer = {
        mason = false,
      },
    },
    setup = {
      rust_analyzer = function(_, opts)
        require("rust-tools").setup({ server = opts })
        return true
      end,
    },
  },
}
