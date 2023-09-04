return {
  "mhartington/formatter.nvim",
  event = "VeryLazy",
  opts = function()
    return {
      filetype = {
        lua = { require("formatter.filetypes.lua").stylua },
        python = { require("formatter.filetypes.python").black },
        json = { require("formatter.filetypes.json").fixjson },
        nix = { require("formatter.filetypes.nix").alejandra },
        javascript = { require("formatter.filetypes.javascript").prettierd },
        typescript = { require("formatter.filetypes.typescript").prettierd },
        kotlin = { require("formatter.filetypes.kotlin").ktlint },
      },
    }
  end,
  config = function(_, opts)
    require("formatter").setup(opts)

    local formatter_group = vim.api.nvim_create_augroup("Formatter", {})

    vim.api.nvim_create_autocmd("BufWritePost", {
      group = formatter_group,
      callback = function()
        vim.cmd("FormatWriteLock")
      end,
    })

    vim.api.nvim_create_autocmd("User", {
      group = formatter_group,
      pattern = "FormatterPre",
      callback = function()
        vim.b.formatter_running = true
      end,
    })

    vim.api.nvim_create_autocmd("User", {
      group = formatter_group,
      pattern = "FormatterPost",
      callback = function()
        vim.b.formatter_running = false
      end,
    })
  end,
}
