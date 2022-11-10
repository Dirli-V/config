local which_key = require "which-key"
local M = {}

M.setup = function()
  local signs = {
    { name = "DiagnosticSignError", text = "" },
    { name = "DiagnosticSignWarn", text = "" },
    { name = "DiagnosticSignHint", text = "" },
    { name = "DiagnosticSignInfo", text = "" },
  }

  for _, sign in ipairs(signs) do
    vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = "" })
  end

  local config = {
    update_in_insert = true,
    severity_sort = true,
    float = {
      focusable = false,
      style = "minimal",
      border = "rounded",
      source = "always",
      header = "",
      prefix = "",
    },
  }

  vim.diagnostic.config(config)

  vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
    border = "rounded",
  })

  vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
    border = "rounded",
  })
end

local function lsp_highlight_document(client)
  -- Set autocmd conditional on server_capabilities
  if client.server_capabilities.document_highlight then
    vim.api.nvim_exec(
      [[
      augroup lsp_document_highlight
        autocmd! * <buffer>
        autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
        autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
      augroup END
    ]] ,
      false
    )
  end
end

local function lsp_keymaps(bufnr)
  which_key.register({
    ["gD"] = { vim.lsp.buf.declaration, "Goto declaration" },
    ["gd"] = { vim.lsp.buf.definition, "Goto definition" },
    ["gh"] = { vim.lsp.buf.hover, "Show hover text" },
    ["gi"] = { vim.lsp.buf.implementation, "Goto implementation" },
    ["gk"] = { vim.lsp.buf.signature_help, "Show signature help" },
    ["gj"] = { vim.lsp.codelens.run, "Run codelens" },
    ["<F2>"] = { vim.lsp.buf.rename, "Rename" },
    ["gr"] = { "<cmd>Telescope lsp_references<CR>", "Show references" },
    ["<leader>."] = { vim.lsp.buf.code_action, "Open code actions" },
    ["<c-.>"] = { vim.lsp.buf.code_action, "Open code actions" },
    ["<leader>k"] = { vim.diagnostic.goto_prev, "Goto previous diagnostics" },
    ["gl"] = { vim.diagnostic.open_float, "Show line diagnostics" },
    ["<leader>j"] = { vim.diagnostic.goto_next, "Got previous diagnostics" },
    ["<A-l>"] = { vim.lsp.buf.formatting, "Format" },
    ["gS"] = { "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>", "Workspace Symbols" },
    ["gs"] = { "<cmd>Telescope lsp_document_symbols<cr>", "Document Symbols" },
  }, {
    buffer = bufnr,
  })
  vim.cmd [[ command! Format execute 'lua vim.lsp.buf.formatting()' ]]
end

local function dap_keymaps(client, bufnr)
  if client.name == "jdt.ls" then
    local jdtls = require "jdtls"
    which_key.register({
      ["<leader>df"] = { jdtls.test_class, "Test class" },
      ["<leader>dn"] = { jdtls.test_nearest_method, "Test nearest method" },
    }, {
      buffer = bufnr,
    })
  end

  if client.name == "pyright" then
    local dap_python = require "dap-python"
    which_key.register({
      ["<leader>df"] = { dap_python.test_class, "Test class" },
      ["<leader>dn"] = { dap_python.test_nearest_method, "Test nearest method" },
      ["<leader>ds"] = { dap_python.debug_selection, "Debug selection" },
    }, {
      buffer = bufnr,
    })
  end
end

local function server_specific_keymaps(client, bufnr)
  if client.name == "jdt.ls" then
    local jdtls = require "jdtls"
    which_key.register({
      ["<A-o>"] = { jdtls.organize_imports, "Organize imports" },
      ["crv"] = { jdtls.extract_variable, "Extract variable" },
      ["crc"] = { jdtls.extract_constant, "Extract constant" },
      ["crm"] = { function() jdtls.extract_method(true) end, "Extract method" },
    }, {
      buffer = bufnr,
    })
  end

  if client.name == "pyright" then
    which_key.register({
      ["<A-o>"] = { "<Cmd>PyrightOrganizeImports<CR>", "Organize imports" },
    }, {
      buffer = bufnr,
    })
  end

  if client.name == "rust_analyzer" then
    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = bufnr,
      callback = vim.lsp.buf.formatting_sync,
    })
  end
end

M.on_attach = function(client, bufnr)
  if client.name == "tsserver" then
    client.server_capabilities.document_formatting = false
  end
  lsp_keymaps(bufnr)
  dap_keymaps(client, bufnr)
  server_specific_keymaps(client, bufnr)
  lsp_highlight_document(client)
end

local capabilities = vim.lsp.protocol.make_client_capabilities()

local status_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if not status_ok then
  return
end

M.capabilities = cmp_nvim_lsp.default_capabilities(capabilities)

return M
