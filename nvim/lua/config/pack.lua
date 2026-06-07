-- Register PackChanged hook before vim.pack.add() so it catches install events
vim.api.nvim_create_autocmd("PackChanged", {
  callback = function(ev)
    if ev.data.spec.name == "nvim-treesitter" and (ev.data.kind == "install" or ev.data.kind == "update") then
      if not ev.data.active then
        pcall(vim.cmd.packadd, "treesitter-parser-registry")
        vim.cmd.packadd("nvim-treesitter")
      end
      vim.cmd("TSUpdate")
    end
  end,
})

vim.pack.add({
  -- UI / Colors
  { src = "https://github.com/ember-theme/nvim", name = "ember" },
  "https://github.com/nvim-lualine/lualine.nvim",
  "https://github.com/arkav/lualine-lsp-progress",
  "https://github.com/nvim-tree/nvim-web-devicons",
  "https://github.com/monkoose/matchparen.nvim",
  "https://github.com/folke/snacks.nvim",

  -- LSP / Completion
  "https://github.com/Saghen/blink.cmp",
  "https://github.com/xzbdmw/colorful-menu.nvim",
  "https://github.com/folke/lazydev.nvim",
  "https://github.com/Chaitanyabsprip/fastaction.nvim",

  -- Treesitter (neovim-treesitter org: registry + installer; not lazy-loaded)
  "https://github.com/neovim-treesitter/treesitter-parser-registry",
  { src = "https://github.com/neovim-treesitter/nvim-treesitter", version = "main" },
  "https://github.com/HiPhish/rainbow-delimiters.nvim",
  "https://github.com/JoosepAlviste/nvim-ts-context-commentstring",
  { src = "https://github.com/nvim-treesitter/nvim-treesitter-textobjects", version = "main" },
  "https://github.com/nvim-treesitter/nvim-treesitter-context",

  -- Git
  "https://github.com/lewis6991/gitsigns.nvim",
  "https://github.com/sindrets/diffview.nvim",
  "https://github.com/FabijanZulj/blame.nvim",

  -- File navigation
  "https://github.com/cbochs/grapple.nvim",
  "https://github.com/nvim-neo-tree/neo-tree.nvim",
  "https://github.com/nvim-lua/plenary.nvim",
  "https://github.com/MunifTanjim/nui.nvim",

  -- Editing
  "https://github.com/echasnovski/mini.comment",
  "https://github.com/echasnovski/mini.surround",
  "https://github.com/RRethy/vim-illuminate",
  "https://github.com/Aasim-A/scrollEOF.nvim",
  "https://github.com/nvim-pack/nvim-spectre",

  -- Formatting / Linting
  "https://github.com/stevearc/conform.nvim",
  "https://github.com/mfussenegger/nvim-lint",

  -- DAP
  "https://github.com/mfussenegger/nvim-dap",
  "https://github.com/rcarriga/nvim-dap-ui",
  "https://github.com/nvim-neotest/nvim-nio",
  "https://github.com/theHamsta/nvim-dap-virtual-text",
  "https://github.com/mfussenegger/nvim-dap-python",

  -- Testing
  "https://github.com/nvim-neotest/neotest",
  "https://github.com/nvim-neotest/neotest-python",
  "https://github.com/nvim-neotest/neotest-vim-test",
  "https://github.com/vim-test/vim-test",
  "https://github.com/nvim-neotest/neotest-jest",

  -- Language specific
  "https://github.com/mrcjkb/rustaceanvim",
  "https://github.com/pmizio/typescript-tools.nvim",

  -- Diagnostics / UI
  "https://github.com/folke/trouble.nvim",
  "https://github.com/folke/which-key.nvim",

  -- AI
  "https://github.com/github/copilot.vim",
  "https://github.com/supermaven-inc/supermaven-nvim",
})

-- Enable the builtin ui2 (replaces noice.nvim and nvim-notify)
require("vim._core.ui2").enable({})

-- Load plugin configurations.
-- snacks and blink first: Snacks global and LSP capabilities are needed by config.lsp
require("plugins.snacks")
require("plugins.blink")
require("plugins.ember")

require("plugins.blame")
require("plugins.conform")
require("plugins.copilot")
require("plugins.dap")
require("plugins.dapui")
require("plugins.diffview")
require("plugins.fastaction")
require("plugins.gitsigns")
require("plugins.grapple")
require("plugins.illuminate")
require("plugins.lazydev")
require("plugins.lint")
require("plugins.lualine")
require("plugins.matchparen")
require("plugins.minicomment")
require("plugins.minisurround")
require("plugins.neotest")
require("plugins.neotree")
require("plugins.scrolleof")
require("plugins.spectre")
require("plugins.supermaven")
require("plugins.textobjects")
require("plugins.treesitter")
require("plugins.trouble")
require("plugins.typescripttools")
require("plugins.whichkey")
