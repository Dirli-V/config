return {
  "echasnovski/mini.comment",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
  },
  event = "VeryLazy",
  opts = {
    hooks = {
      pre = function()
        require("ts_context_commentstring.internal").update_commentstring()
      end,
    },
  },
  config = function(_, opts)
    require("mini.comment").setup(opts)
  end,
}
