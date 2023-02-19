return {
  "nvim-neorg/neorg",
  build = ":Neorg sync-parsers",
  opts = {
    load = {
      ["core.defaults"] = {}, -- Loads default behaviour
      ["core.norg.concealer"] = {}, -- Adds pretty icons to your documents
      ["core.norg.dirman"] = { -- Manages Neorg workspaces
        config = {
          workspaces = {
            notes = "~/notes",
          },
          default_workspace = "notes",
        },
      },
      ["core.norg.completion"] = {
        config = {
          engine = "nvim-cmp",
        },
      },
    },
  },
  dependencies = { { "nvim-lua/plenary.nvim" } },
  keys = {
    { "<leader>ni", "<cmd>Neorg index<cr>", desc = "Neorg index" },
    { "<leader>nr", "<cmd>Neorg return<cr>", desc = "Neorg return" },
  },
}
