return {
  "nvim-neotest/neotest",
  dependencies = {
    "nvim-neotest/neotest-python",
    "rouge8/neotest-rust",
  },
  -- stylua: ignore
  keys = {
    { "<leader>dd", function() require("neotest").run.run(vim.fn.expand("%")) end, desc = "Run tests in file" },
    { "<leader>dj", function() require("neotest").run.run({strategy = "dap"}) end, desc = "Run nearest test" },
    { "<leader>do", function() require("neotest").output.open({ enter = true }) end, desc = "Open test output" },
  },
  opts = {},
  config = function(_, _)
    require("neotest").setup({
      adapters = {
        require("neotest-python"),
        require("neotest-rust"),
      },
    })
  end,
}
