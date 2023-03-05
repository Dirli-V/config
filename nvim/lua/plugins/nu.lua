return {
  "LhKipp/nvim-nu",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "jose-elias-alvarez/null-ls.nvim",
  },
  ft = "nu",
  bulld = ":TSInstall nu",
  config = function(_, _)
    require("nu").setup()
  end,
}
