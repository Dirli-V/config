return {
  "nvim-neotest/neotest",
  dependencies = {
    "mfussenegger/nvim-dap",
    "nvim-neotest/neotest-python",
    "rouge8/neotest-rust",
    "nvim-neotest/neotest-vim-test",
    "vim-test/vim-test",
    "nvim-neotest/neotest-jest",
  },
  keys = {
    {
      "<leader>dr",
      function()
        vim.cmd("w")
        require("neotest").run.run({
          vim.fn.expand("%"),
          cwd = require("helpers").get_root(),
          suite = false,
        })
      end,
      desc = "Run tests in file",
    },
    {
      "<leader>dd",
      function()
        vim.cmd("w")
        require("neotest").run.run({
          vim.fn.expand("%"),
          strategy = "dap",
          cwd = require("helpers").get_root(),
          suite = false,
        })
      end,
      desc = "Debug tests in file",
    },
    {
      "<leader>dj",
      function()
        vim.cmd("w")
        require("neotest").run.run({
          cwd = require("helpers").get_root(),
          suite = false,
        })
      end,
      desc = "Run nearest test",
    },
    {
      "<leader>dJ",
      function()
        vim.cmd("w")
        require("neotest").run.run({
          strategy = "dap",
          cwd = require("helpers").get_root(),
          suite = false,
        })
      end,
      desc = "Debug nearest test",
    },
    {
      "<leader>do",
      function()
        require("neotest").output.open({
          enter = true,
        })
      end,
      desc = "Open test output",
    },
    {
      "<leader>ds",
      function()
        require("neotest").run.stop()
      end,
      desc = "Stop nearest test",
    },
    {
      "<leader>dl",
      function()
        require("neotest").summary.toggle()
      end,
      desc = "List tests",
    },
    {
      "<leader>dn",
      function()
        require("neotest").jump.next()
      end,
      desc = "Jump to next test",
    },
    {
      "<leader>dN",
      function()
        require("neotest").jump.prev()
      end,
      desc = "Jump to prev test",
    },
  },
  opts = {
    status = { virtual_text = true },
  },
  config = function(_, _)
    require("neotest").setup({
      adapters = {
        require("neotest-python"),
        require("neotest-rust"),
        require("neotest-jest"),
        require("neotest-vim-test")({
          allow_file_types = { "java", "kotlin" },
        }),
      },
    })
  end,
}
