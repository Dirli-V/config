---@type vim.lsp.Config
return {
  cmd = { "typos-lsp" },
  single_file_support = true,
  root_markers = { "typos.toml", "_typos.toml", ".typos.toml" },
}
