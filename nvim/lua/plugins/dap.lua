return {
  "mfussenegger/nvim-dap",
  dependencies = {
    "rcarriga/nvim-dap-ui",
    "theHamsta/nvim-dap-virtual-text",
    "mfussenegger/nvim-dap-python",
  },
  keys = {
    {
      "<F5>",
      function()
        require("dap").continue()
      end,
      desc = "Continue",
    },
    {
      "<F10>",
      function()
        require("dap").step_over()
      end,
      desc = "Step over",
    },
    {
      "<F11>",
      function()
        require("dap").step_into()
      end,
      desc = "Step into",
    },
    {
      "<F12>",
      function()
        require("dap").step_out()
      end,
      desc = "Step out",
    },
    {
      "<leader>db",
      function()
        require("dap").toggle_breakpoint()
      end,
      desc = "Toggle breakpoint",
    },
    {
      "<leader>dB",
      function()
        require("dap").set_breakpoint(vim.fn.input({ prompt = "Condition: " }))
      end,
      desc = "Conditional breakpoint",
    },
  },
  config = function(_, _)
    local icons = require("config.icons").dap
    for name, sign in pairs(icons) do
      sign = type(sign) == "table" and sign or { sign }
      vim.fn.sign_define(
        "Dap" .. name,
        { text = sign[1], texthl = sign[2] or "DiagnosticInfo", linehl = sign[3], numhl = sign[3] }
      )
    end

    local dap = require("dap")

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

    require("dap-python").setup(vim.fn.exepath("python"))
  end,
}
