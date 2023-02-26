return {
  "ldelossa/litee-symboltree.nvim",
  dependencies = { "ldelossa/litee.nvim" },
  keys = {
    { "<leader>cs", vim.lsp.buf.document_symbol, desc = "Symboltree" },
  },
  opts = {
    on_open = "panel",
  },
  config = function(_, opts)
    require("litee.lib").setup({
      panel = {
        orientation = "right",
        panel_size = 30,
      },
    })
    require("litee.symboltree").setup(opts)
  end,
}
