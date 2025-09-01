local M = {}

function M.diagnostic_goto(next, severity)
  local go = next and vim.diagnostic.goto_next or vim.diagnostic.goto_prev
  severity = severity and vim.diagnostic.severity[severity] or nil
  return function()
    go({ severity = severity })
  end
end

local lsp_keys = {
  { "gl", vim.diagnostic.open_float, desc = "Line Diagnostics" },
  { "gd", Snacks.picker.lsp_definitions, desc = "Goto Definition" },
  { "gr", Snacks.picker.lsp_references, desc = "References" },
  { "gD", Snacks.picker.lsp_declarations, desc = "Goto Declaration" },
  { "gi", Snacks.picker.lsp_implementations, desc = "Goto Implementation" },
  { "gy", Snacks.picker.lsp_type_definitions, desc = "Goto Type Definition" },
  { "K", vim.lsp.buf.hover, desc = "Hover" },
  { "gk", vim.lsp.buf.signature_help, desc = "Signature Help" },
  { "<c-k>", vim.lsp.buf.signature_help, mode = "i", desc = "Signature Help" },
  { "<leader>j", M.diagnostic_goto(true), desc = "Next Diagnostic" },
  { "<leader>k", M.diagnostic_goto(false), desc = "Prev Diagnostic" },
  { "]e", M.diagnostic_goto(true, "ERROR"), desc = "Next Error" },
  { "[e", M.diagnostic_goto(false, "ERROR"), desc = "Prev Error" },
  { "]w", M.diagnostic_goto(true, "WARN"), desc = "Next Warning" },
  { "[w", M.diagnostic_goto(false, "WARN"), desc = "Prev Warning" },
  { "<leader>cr", vim.lsp.buf.rename, desc = "Rename" },
  { "<F2>", vim.lsp.buf.rename, desc = "Rename" },
  {
    "<c-.>",
    function()
      require("fastaction").code_action()
    end,
    mode = { "n", "i" },
    desc = "Open code actions",
  },
  { "<leader>.", vim.lsp.buf.code_action, desc = "Open code actions" },
  { "<leader>c.", require("helpers").list_code_action_kinds, desc = "List code action kinds" },
}

local rust_analyzer_keys = {
  { "J", "<cmd>RustLsp joinLines<cr>", mode = { "n", "x" }, desc = "Join lines" },
  {
    "K",
    function()
      vim.cmd.RustLsp({ "hover", "actions" })
    end,
    desc = "Hover actions",
  },
}

function M.on_attach(client, buffer)
  for _, keys in pairs(lsp_keys) do
    local opts = {}
    opts.desc = keys.opts or ""
    opts.silent = opts.silent ~= false
    opts.buffer = buffer
    vim.keymap.set(keys.mode or "n", keys[1], keys[2], opts)
  end

  if client.name == "rust-analyzer" then
    for _, keys in pairs(rust_analyzer_keys) do
      local opts = {}
      opts.desc = keys.opts or ""
      opts.silent = opts.silent ~= false
      opts.buffer = buffer
      vim.keymap.set(keys.mode or "n", keys[1], keys[2], opts)
    end
  end
end

vim.api.nvim_create_autocmd("LspAttach", {
  desc = "Setup LSP keymaps",
  callback = function(args)
    local buffer = args.buf
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    M.on_attach(client, buffer)
  end,
})

local capabilities = {
  textDocument = {
    foldingRange = {
      dynamicRegistration = false,
      lineFoldingOnly = true,
    },
  },
}

capabilities = require("blink.cmp").get_lsp_capabilities(capabilities)

vim.lsp.config("*", {
  capabilities = capabilities,
  root_markers = { ".git" },
})

vim.lsp.enable({
  "bashls",
  "gopls",
  "intelephense",
  "jdtls",
  "jsonls",
  "luals",
  "nixd",
  "pyright",
  "taplo",
  "typos",
  "yamlls",
})

return M
