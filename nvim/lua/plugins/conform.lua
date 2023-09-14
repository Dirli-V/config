return {
  "stevearc/conform.nvim",
  event = "VeryLazy",
  opts = {
    formatters_by_ft = {
      lua = { "stylua" },
      python = { "isort", "black" },
      javascript = { "prettierd" },
      typescript = { "prettierd" },
      nix = { "alejandra" },
      json = { "fixjson" },
      kotlin = { "ktlint" },
    },
    format_on_save = false,
    formatters = {
      alejandra = {
        command = "alejandra",
        stdin = true,
        args = { "--quiet" },
      },
      fixjson = {
        command = "fixjson",
        args = { "--stdin-filename", "$FILENAME" },
        stdin = true,
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
