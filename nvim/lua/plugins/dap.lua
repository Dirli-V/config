local icons = require("config.icons").dap
for name, sign in pairs(icons) do
  vim.fn.sign_define(
    "Dap" .. name,
    { text = sign[1], texthl = sign[2] or "DiagnosticInfo", linehl = sign[3], numhl = sign[3] }
  )
end

local dap = require("dap")

dap.adapters["lldb-dap"] = {
  type = "executable",
  command = vim.fn.exepath("lldb-dap"),
  name = "lldb-dap",
}

require("dap-python").setup(vim.fn.exepath("python"))

vim.keymap.set("n", "<F5>", function() require("dap").continue() end, { desc = "Continue" })
vim.keymap.set("n", "<F10>", function() require("dap").step_over() end, { desc = "Step over" })
vim.keymap.set("n", "<F11>", function() require("dap").step_into() end, { desc = "Step into" })
vim.keymap.set("n", "<F12>", function() require("dap").step_out() end, { desc = "Step out" })
vim.keymap.set("n", "<leader>db", function() require("dap").toggle_breakpoint() end, { desc = "Toggle breakpoint" })
vim.keymap.set("n", "<leader>dB", function()
  require("dap").set_breakpoint(vim.fn.input({ prompt = "Condition: " }))
end, { desc = "Conditional breakpoint" })
