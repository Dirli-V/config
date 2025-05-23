---@type vim.lsp.Config
return {
  cmd = { "bash-language-server", "start" },
  filetypes = { "sh", "bash" },
  single_file_support = true,
  root_markers = { ".git" },
  settings = {
    bashIde = {
      globPattern = vim.env.GLOB_PATTERN or "*@(.sh|.inc|.bash|.command)",
    },
  },
}
