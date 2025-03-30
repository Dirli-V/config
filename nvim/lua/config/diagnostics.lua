for name, icon in pairs(require("config.icons").diagnostics) do
  name = "DiagnosticSign" .. name
  vim.fn.sign_define(name, { text = icon, texthl = name, numhl = "" })
end
vim.diagnostic.config({
  underline = true,
  virtual_text = {
    spacing = 4,
    source = "if_many",
  },
  severity_sort = true,
  update_in_insert = true,
})
