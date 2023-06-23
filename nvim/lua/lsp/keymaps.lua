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

local function cursor_not_on_result(result)
  local target_uri = result.targetUri or result.uri
  local target_range = result.targetRange or result.range

  local target_bufnr = vim.uri_to_bufnr(target_uri)
  local target_row_start = target_range.start.line + 1
  local target_row_end = target_range["end"].line + 1
  local target_col_start = target_range.start.character + 1
  local target_col_end = target_range["end"].character + 1

  local current_bufnr = vim.fn.bufnr()
  local current_range = vim.api.nvim_win_get_cursor(0)
  local current_row = current_range[1]
  local current_col = current_range[2] + 1

  return target_bufnr ~= current_bufnr
    or current_row < target_row_start
    or current_row > target_row_end
    or (current_row == target_row_start and current_col < target_col_start)
    or (current_row == target_row_end and current_col > target_col_end)
end

local function definition_or_reference()
  local conf = require("telescope.config").values
  local finders = require("telescope.finders")
  local make_entry = require("telescope.make_entry")
  local pickers = require("telescope.pickers")

  local params = vim.lsp.util.make_position_params()
  vim.lsp.buf_request(0, "textDocument/definition", params, function(err, result, ctx, _)
    if err then
      vim.api.nvim_err_writeln("Error requesting definitions: " .. err.message)
      return
    end
    local flattened_results = {}
    if result then
      -- textDocument/definition can return Location or Location[]
      if not vim.tbl_islist(result) then
        flattened_results = { result }
      end

      vim.list_extend(flattened_results, result)
    end

    local offset_encoding = vim.lsp.get_client_by_id(ctx.client_id).offset_encoding

    if #flattened_results == 0 then
      return
    end

    if #flattened_results == 1 then
      if cursor_not_on_result(flattened_results[1]) then
        vim.lsp.util.jump_to_location(flattened_results[1], offset_encoding, true)
        return
      end

      vim.cmd("Telescope lsp_references")
      return
    end

    local locations = vim.lsp.util.locations_to_items(flattened_results, offset_encoding)
    pickers
      .new({}, {
        prompt_title = "LSP Definitions",
        finder = finders.new_table({
          results = locations,
          entry_maker = make_entry.gen_from_quickfix({}),
        }),
        previewer = conf.qflist_previewer({}),
        sorter = conf.generic_sorter({}),
        push_cursor_on_edit = true,
        push_tagstack_on_edit = true,
      })
      :find()
  end)
end

LspKeys = {
  { "gl", vim.diagnostic.open_float, desc = "Line Diagnostics" },
  { "gd", definition_or_reference, desc = "Goto Definition" },
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
