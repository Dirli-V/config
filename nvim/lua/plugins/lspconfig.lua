return {
  "neovim/nvim-lspconfig",
  dependencies = { "simrat39/rust-tools.nvim" },
  opts = {
    diagnostics = {
      update_in_insert = true,
    },
    setup = {
      rust_analyzer = function(_, opts)
        require("rust-tools").setup({ server = opts })
        return true
      end,
    },
  },
}
