return {
  "catppuccin/nvim",
  name = "catppuccin",
  lazy = false,
  priority = 1000,
  opts = {
    integrations = {
      illuminate = true,
      harpoon = true,
      leap = true,
      mini = true,
      neotree = true,
      neotest = true,
      noice = true,
      notify = true,
      treesitter_context = true,
      lsp_trouble = true,
      which_key = true,
    },
  },
  config = function(_, opts)
    require("catppuccin").setup(opts)
    vim.cmd([[colorscheme catppuccin-mocha]])
  end,
}
