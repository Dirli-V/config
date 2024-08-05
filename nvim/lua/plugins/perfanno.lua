return {
  "t-troebst/perfanno.nvim",
  keys = {
    { "<LEADER>plf", ":PerfLoadFlat<CR>", desc = "PerfLoadFlat<CR>" },
    { "<LEADER>plg", ":PerfLoadCallGraph<CR>", desc = "PerfLoadCallGraph" },
    { "<LEADER>plo", ":PerfLoadFlameGraph<CR>", desc = "PerfLoadFlameGraph" },
    { "<LEADER>pe", ":PerfPickEvent<CR>", desc = "PerfPickEvent" },
    { "<LEADER>pa", ":PerfAnnotate<CR>", desc = "PerfAnnotate" },
    { "<LEADER>pf", ":PerfAnnotateFunction<CR>", desc = "PerfAnnotateFunction" },
    { "<LEADER>pa", ":PerfAnnotateSelection<CR>", desc = "PerfAnnotateSelection" },
    { "<LEADER>pt", ":PerfToggleAnnotations<CR>", desc = "PerfToggleAnnotations" },
    { "<LEADER>ph", ":PerfHottestLines<CR>", desc = "PerfHottestLines" },
    { "<LEADER>ps", ":PerfHottestSymbols<CR>", desc = "PerfHottestSymbols" },
    { "<LEADER>pc", ":PerfHottestCallersFunction<CR>", desc = "PerfHottestCallersFunction" },
    { "<LEADER>pc", ":PerfHottestCallersSelection<CR>", desc = "PerfHottestCallersSelection", mode = { "x" } },
  },
  config = function()
    local perfanno = require("perfanno")
    local util = require("perfanno.util")

    local bgcolor = vim.fn.synIDattr(vim.fn.hlID("Normal"), "bg", "gui")

    perfanno.setup({
      -- Creates a 10-step RGB color gradient beween bgcolor and "#CC3300"
      line_highlights = util.make_bg_highlights(bgcolor, "#CC3300", 10),
      vt_highlight = util.make_fg_highlight("#CC3300"),
    })
  end,
}
