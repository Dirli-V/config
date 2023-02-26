return {
  "ldelossa/litee-calltree.nvim",
  dependencies = { "ldelossa/litee.nvim" },
  keys = {
    { "<leader>co", vim.lsp.buf.outgoing_calls, desc = "Calltree outgoing calls" },
    { "<leader>ci", vim.lsp.buf.incoming_calls, desc = "Calltree incoming calls" },
  },
  opts = {
    on_open = "panel",
  },
  config = function(_, opts)
    require("litee.lib").setup({})
    require("litee.calltree").setup(opts)
  end,
}
