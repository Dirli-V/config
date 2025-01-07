return {
  "stevearc/conform.nvim",
  event = "VeryLazy",
  opts = {
    formatters_by_ft = {
      lua = { "stylua" },
      python = { "isort", "black" },
      javascript = { "prettierd" },
      typescript = { "prettierd" },
      typescriptreact = { "prettierd" },
      html = { "prettierd", "djlint" },
      htmldjango = { "prettierd", "djlint" },
      nix = { "alejandra" },
      json = { "jq" },
      kotlin = { "ktlint" },
    },
    format_on_save = false,
    formatters = {
      alejandra = {
        command = "alejandra",
        stdin = true,
        args = { "--quiet" },
      },
      ktlint = {
        command = "ktlint",
        args = {
          "--stdin",
          "--format",
          "--log-level=none",
        },
        stdin = true,
      },
    },
  },
}
