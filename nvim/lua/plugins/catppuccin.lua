require("catppuccin").setup({
  integrations = {
    illuminate = true,
    harpoon = true,
    leap = true,
    mini = true,
    neotree = true,
    neotest = true,
    lsp_trouble = true,
    which_key = true,
  },
})
vim.cmd([[colorscheme catppuccin-mocha]])
