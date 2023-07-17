return {
  "folke/persistence.nvim",
  event = "BufReadPre",
  opts = { options = { "buffers", "curdir", "tabpages", "winsize", "help", "globals" } },
  keys = {
    {
      "<leader>br",
      function()
        require("persistence").load()
      end,
      desc = "Restore Session",
    },
    {
      "<leader>bl",
      function()
        require("persistence").load({ last = true })
      end,
      desc = "Restore Last Session",
    },
    {
      "<leader>bs",
      function()
        require("persistence").stop()
      end,
      desc = "Don't Save Current Session",
    },
  },
  config = function(_, opts)
    if 0 == vim.fn.argc(-1) then
      require("persistence").setup(opts)
    end
  end,
}
