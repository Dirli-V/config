local Util = require("lazy.core.util")

local M = {}

M.autoformat = true

function M.toggle()
  M.autoformat = not M.autoformat

  if M.autoformat then
    Util.info("Enabled format on save", { title = "Format" })
  else
    Util.warn("Disabled format on save", { title = "Format" })
  end
end

function M.format()
  local buf = vim.api.nvim_get_current_buf()
  require("conform").format({ timeout_ms = 500, lsp_fallback = true, buf = buf })
end

vim.api.nvim_create_autocmd("BufWritePre", {
  group = vim.api.nvim_create_augroup("FormatOnSave", {}),
  callback = function()
    if M.autoformat then
      M.format()
    end
  end,
})

return M
