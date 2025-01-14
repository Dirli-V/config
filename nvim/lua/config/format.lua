local Util = require("lazy.core.util")

local M = {}

M.autoformat = {}

function M.toggle()
  local ft = vim.bo.filetype
  if M.autoformat[ft] == nil then
    M.autoformat[ft] = true
  end
  local current = M.autoformat[ft]
  local next = not current
  M.autoformat[ft] = next

  if next then
    Util.info("Enabled format on save for " .. ft, { title = "Format" })
  else
    Util.warn("Disabled format on save for " .. ft, { title = "Format" })
  end
end

function M.format()
  local buf = vim.api.nvim_get_current_buf()
  require("conform").format({ timeout_ms = 1000, lsp_fallback = true, buf = buf })
end

vim.api.nvim_create_autocmd("BufWritePre", {
  group = vim.api.nvim_create_augroup("FormatOnSave", {}),
  callback = function()
    local ft = vim.bo.filetype
    if M.autoformat[ft] == nil or M.autoformat[ft] then
      M.format()
    end
  end,
})

return M
