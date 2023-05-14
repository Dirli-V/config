return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  event = { "BufReadPost", "BufNewFile" },
  dependencies = {
    "HiPhish/nvim-ts-rainbow2",
    "JoosepAlviste/nvim-ts-context-commentstring",
    "nvim-treesitter/nvim-treesitter-textobjects",
    "nvim-treesitter/nvim-treesitter-context"
  },
  keys = {
    { "<bs>", desc = "Increment selection" },
    { "<del>", desc = "Decrement selection", mode = "x" },
  },
  opts = {
    ensure_installed = "all",
    highlight = { enable = true },
    indent = { enable = true },
    context_commentstring = { enable = true, enable_autocmd = false },
    rainbow = {
      enable = true,
    },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = "<bs>",
        node_incremental = "<bs>",
        scope_incremental = false,
        node_decremental = "<del>",
      },
    },
  },
  config = function(_, opts)
    require("nvim-treesitter.configs").setup(opts)
  end,
}
