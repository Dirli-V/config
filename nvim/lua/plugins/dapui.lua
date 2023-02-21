return {
  "rcarriga/nvim-dap-ui",
  dependencies = { "mfussenegger/nvim-dap" },
  -- stylua: ignore
  keys = {
    { "<leader>dt", function() require("dapui").toggle() end, desc = "Toggle Debug UI" },
  },
  config = function(_, opts)
    local dap, dapui = require("dap"), require("dapui")
    dapui.setup(opts)
    dap.listeners.after.event_initialized["dapui_config"] = dapui.open
    dap.listeners.before.event_terminated["dapui_config"] = dapui.close
    dap.listeners.before.event_exited["dapui_config"] = dapui.close
  end,
}
