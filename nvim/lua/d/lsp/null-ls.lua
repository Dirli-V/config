local null_ls_status_ok, null_ls = pcall(require, "null-ls")
if not null_ls_status_ok then
  return
end

-- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins/formatting
local formatting = null_ls.builtins.formatting
local diagnostics = null_ls.builtins.diagnostics
local code_actions = null_ls.builtins.code_actions
-- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins/diagnostics
-- local diagnostics = null_ls.builtins.diagnostics

null_ls.setup({
  debug = true,
  sources = {
    diagnostics.chktex,
    diagnostics.codespell.with({
      args = {
        "--ignore-words",
        vim.fn.stdpath "config" .. "/../codespell/ignore_words.txt",
        "-",
      },
    }),
    diagnostics.cspell.with({
      extra_args = {
        "--config",
        vim.fn.stdpath "config" .. "/../cspell/config.json",
      },
      diagnostics_postprocess = function(diagnostic)
        diagnostic.severity = vim.diagnostic.severity["INFO"]
      end,
      disabled_filetypes = { "NvimTree" },
    }),
    diagnostics.jsonlint,
    diagnostics.stylelint,
    code_actions.proselint,
    formatting.autopep8,
    formatting.stylua,
  },
  on_attach = require("d.lsp.handlers").on_attach,
})
