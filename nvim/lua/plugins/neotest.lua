return {
  "nvim-neotest/neotest",
  dependencies = {
    "nvim-neotest/neotest-python",
    "rouge8/neotest-rust",
  },
  -- stylua: ignore
  keys = {
    { "<leader>dr", function() require("neotest").run.run(vim.fn.expand("%")) end, desc = "Run tests in file" },
    { "<leader>dd", function() require("neotest").run.run({ vim.fn.expand("%"), strategy = "dap" }) end, desc = "Debug tests in file" },
    { "<leader>dj", function() require("neotest").run.run() end, desc = "Run nearest test" },
    { "<leader>dJ", function() require("neotest").run.run({ strategy = "dap" }) end, desc = "Debug nearest test" },
    { "<leader>do", function() require("neotest").output.open({ enter = true }) end, desc = "Open test output" },
    { "<leader>ds", function() require("neotest").run.stop() end, desc = "Stop nearest test" },
    { "<leader>dl", function() require("neotest").summary.toggle() end, desc = "List tests" },
    { "<leader>dn", function() require("neotest").jump.next() end, desc = "Jump to next test" },
    { "<leader>dN", function() require("neotest").jump.prev() end, desc = "Jump to prev test" },
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
