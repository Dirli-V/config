return {
  "folke/persistence.nvim",
  -- stylua: ignore
  keys = {
    { "<leader>qs", false },
    { "<leader>ql", false },
    { "<leader>qd", false },
    { "<leader>br", function() require("persistence").load() end, desc = "Restore Session" },
    { "<leader>bl", function() require("persistence").load({ last = true }) end, desc = "Restore Last Session" },
    { "<leader>bs", function() require("persistence").stop() end, desc = "Don't Save Current Session" },
  },
}
