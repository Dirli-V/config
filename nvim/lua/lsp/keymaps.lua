local M = {}

function M.diagnostic_goto(next, severity)
  local go = next and vim.diagnostic.goto_next or vim.diagnostic.goto_prev
  severity = severity and vim.diagnostic.severity[severity] or nil
  return function()
    go({ severity = severity })
  end
end

local format = function()
  require("lsp.format").format({ force = true })
end

LspKeys = {
  { "gl", vim.diagnostic.open_float, desc = "Line Diagnostics" },
  { "gd", "<cmd>Telescope lsp_definitions<cr>", desc = "Goto Definition" },
  { "gr", "<cmd>Telescope lsp_references<cr>", desc = "References" },
  { "gD", vim.lsp.buf.declaration, desc = "Goto Declaration" },
  { "gI", "<cmd>Telescope lsp_implementations<cr>", desc = "Goto Implementation" },
  { "gy", "<cmd>Telescope lsp_type_definitions<cr>", desc = "Goto Type Definition" },
  { "K", vim.lsp.buf.hover, desc = "Hover" },
  { "gK", vim.lsp.buf.signature_help, desc = "Signature Help" },
  { "<c-k>", vim.lsp.buf.signature_help, mode = "i", desc = "Signature Help" },
  { "<leader>j", M.diagnostic_goto(true), desc = "Next Diagnostic" },
  { "<leader>k", M.diagnostic_goto(false), desc = "Prev Diagnostic" },
  { "]e", M.diagnostic_goto(true, "ERROR"), desc = "Next Error" },
  { "[e", M.diagnostic_goto(false, "ERROR"), desc = "Prev Error" },
  { "]w", M.diagnostic_goto(true, "WARN"), desc = "Next Warning" },
  { "[w", M.diagnostic_goto(false, "WARN"), desc = "Prev Warning" },
  { "<a-l>", format, desc = "Format Document" },
  { "<a-l>", format, desc = "Format Range", mode = "v" },
  { "<leader>cr", vim.lsp.buf.rename, desc = "Rename" },
  { "<F2>", vim.lsp.buf.rename, desc = "Rename" },
  {
    "<c-.>",
    function()
      require("actions-preview").code_actions()
    end,
    desc = "Open code actions",
  },
  { "<leader>.", vim.lsp.buf.code_action, desc = "Open code actions" },
  { "<leader>c.", require("helpers").list_code_action_kinds, desc = "List code action kinds" },
}

function M.on_attach(_, buffer)
  local Keys = require("lazy.core.handler.keys")

  for _, keys in pairs(LspKeys) do
    local parsedKeys = Keys.parse(keys)
    local opts = Keys.opts(parsedKeys)
    opts.silent = opts.silent ~= false
    opts.buffer = buffer
    vim.keymap.set(parsedKeys.mode or "n", parsedKeys[1], parsedKeys[2], opts)
  end
end

return M
