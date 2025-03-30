---@type vim.lsp.Config
return {
  cmd = { "vscode-json-languageserver", "--stdio" },
  filetypes = { "json", "jsonc", "json5" },
  single_file_support = true,
  root_markers = { ".git" },
}
