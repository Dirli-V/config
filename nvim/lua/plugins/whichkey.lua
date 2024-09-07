return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    {
      mode = { "n", "v" },
      { "g", group = "goto" },
      { "gz", group = "surround" },
      { "]", group = "next" },
      { "[", group = "prev" },
      { "<leader><tab>", group = "tabs" },
      { "<leader>b", group = "buffer" },
      { "<leader>c", group = "code" },
      { "<leader>g", group = "git" },
      { "<leader>s", group = "search" },
      { "<leader>d", group = "debug" },
      { "<leader>u", group = "ui" },
      { "<leader>x", group = "diagnostics/quickfix" },
      { "<leader>n", group = "note" },
      { "<leader>y", group = "misc" },
      { "<leader>p", group = "perf" },
    },
  },
}
