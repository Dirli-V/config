return {
  "nvim-treesitter/nvim-treesitter",
  dependencies = {
    "HiPhish/nvim-ts-rainbow2",
    "JoosepAlviste/nvim-ts-context-commentstring",
  },
  opts = {
    ensure_installed = "all",
    rainbow = {
      enable = true,
    },
  },
}
