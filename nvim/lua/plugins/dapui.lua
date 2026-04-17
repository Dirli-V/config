local dap, dapui = require("dap"), require("dapui")
dapui.setup()
dap.listeners.after.event_breakpoint["dapui_config"] = dapui.open
dap.listeners.before.event_terminated["dapui_config"] = dapui.close
dap.listeners.before.event_exited["dapui_config"] = dapui.close

vim.keymap.set("n", "<leader>dt", function() require("dapui").toggle() end, { desc = "Toggle Debug UI" })
