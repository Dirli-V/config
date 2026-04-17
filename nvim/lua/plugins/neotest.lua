require("neotest").setup({
  adapters = {
    require("neotest-python"),
    require("rustaceanvim.neotest"),
    require("neotest-jest"),
    require("neotest-vim-test")({ allow_file_types = { "java", "kotlin" } }),
  },
})

vim.keymap.set("n", "<leader>dr", function()
  vim.cmd("up")
  require("neotest").run.run({
    vim.fn.expand("%"),
    cwd = require("helpers").get_root(),
    suite = false,
  })
end, { desc = "Run tests in file" })

vim.keymap.set("n", "<leader>dd", function()
  vim.cmd("up")
  require("neotest").run.run({
    vim.fn.expand("%"),
    strategy = "dap",
    cwd = require("helpers").get_root(),
    suite = false,
  })
end, { desc = "Debug tests in file" })

vim.keymap.set("n", "<leader>dj", function()
  vim.cmd("up")
  require("neotest").run.run({
    cwd = require("helpers").get_root(),
    suite = false,
  })
end, { desc = "Run nearest test" })

vim.keymap.set("n", "<leader>dJ", function()
  vim.cmd("up")
  require("neotest").run.run({
    strategy = "dap",
    cwd = require("helpers").get_root(),
    suite = false,
  })
end, { desc = "Debug nearest test" })

vim.keymap.set("n", "<leader>do", function()
  require("neotest").output.open({ enter = true })
end, { desc = "Open test output" })

vim.keymap.set("n", "<leader>ds", function()
  require("neotest").run.stop()
end, { desc = "Stop nearest test" })

vim.keymap.set("n", "<leader>dl", function()
  require("neotest").summary.toggle()
end, { desc = "List tests" })

vim.keymap.set("n", "<leader>dn", function()
  require("neotest").jump.next()
end, { desc = "Jump to next test" })

vim.keymap.set("n", "<leader>dN", function()
  require("neotest").jump.prev()
end, { desc = "Jump to prev test" })
