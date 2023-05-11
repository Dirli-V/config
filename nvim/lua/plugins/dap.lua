return {
  "mfussenegger/nvim-dap",
  dependencies = {
    "theHamsta/nvim-dap-virtual-text",
    "mfussenegger/nvim-dap-python",
  },
  -- stylua: ignore
  keys = {
    { "<F5>", function() require("dap").continue() end, desc = "Continue" },
    { "<F10>", function() require("dap").step_over() end, desc = "Step over" },
    { "<F11>", function() require("dap").step_into() end, desc = "Step into" },
    { "<F12>", function() require("dap").step_out() end, desc = "Step out" },
  },
  config = function(_, _)
    local dap = require("dap")
    require("dap-python").setup(vim.fn.exepath("python"))

    dap.adapters.lldb = {
      type = "executable",
      command = vim.fn.exepath("lldb-vscode"),
      name = "lldb",
    }

    dap.configurations.rust = {
      {
        name = "Launch",
        type = "lldb",
        request = "launch",
        program = function()
          return vim.fn.input({ prompt = "Path to executable: ", default = vim.fn.getcwd() .. "/", completion = "file" })
        end,
        cwd = "${workspaceFolder}",
        stopOnEntry = false,
        args = {},
      },
    }
  end,
}
