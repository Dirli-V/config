return {
  "FabijanZulj/blame.nvim",
  config = function()
    require("blame").setup()
  end,
  cmd = "BlameToggle",
  keys = {
    { "<leader>gb", "<cmd>BlameToggle<cr>", desc = "Toggle blame" },
  },
}
