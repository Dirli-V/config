-- Tree-sitter incremental selection without legacy nvim-treesitter.configs.
local api = vim.api
local ts = vim.treesitter

local M = {}

---@type table<integer, TSNode[]>
local selections = {}

local function get_vim_range(node, buf)
  local srow, scol, erow, ecol = ts.get_node_range(node)
  srow = srow + 1
  scol = scol + 1
  erow = erow + 1
  if ecol == 0 then
    erow = erow - 1
    if not buf or buf == 0 then
      ecol = vim.fn.col({ erow, "$" }) - 1
    else
      local line = api.nvim_buf_get_lines(buf, erow - 1, erow, false)[1] or ""
      ecol = #line
    end
    ecol = math.max(ecol, 1)
  end
  return srow, scol, erow, ecol
end

---@return integer, integer, integer, integer
local function visual_selection_range()
  local _, csrow, cscol, _ = unpack(vim.fn.getpos("v"))
  local _, cerow, cecol, _ = unpack(vim.fn.getpos("."))
  local start_row, start_col, end_row, end_col
  if csrow < cerow or (csrow == cerow and cscol <= cecol) then
    start_row = csrow
    start_col = cscol
    end_row = cerow
    end_col = cecol
  else
    start_row = cerow
    start_col = cecol
    end_row = csrow
    end_col = cscol
  end
  return start_row, start_col, end_row, end_col
end

---@param node TSNode
---@return boolean
local function range_matches_visual(node, buf)
  local csrow, cscol, cerow, cecol = visual_selection_range()
  local srow, scol, erow, ecol = get_vim_range(node, buf)
  return srow == csrow and scol == cscol and erow == cerow and ecol == cecol
end

local function update_selection(buf, node)
  local start_row, start_col, end_row, end_col = get_vim_range(node, buf)
  local selection_mode = "v"
  local mode = api.nvim_get_mode()
  if mode.mode ~= selection_mode then
    selection_mode = api.nvim_replace_termcodes(selection_mode, true, true, true)
    api.nvim_cmd({ cmd = "normal", bang = true, args = { selection_mode } }, {})
  end
  api.nvim_win_set_cursor(0, { start_row, start_col - 1 })
  vim.cmd("normal! o")
  api.nvim_win_set_cursor(0, { end_row, end_col - 1 })
end

function M.init_selection()
  local buf = api.nvim_get_current_buf()
  local ok, parser = pcall(ts.get_parser, buf)
  if not ok or not parser then
    return
  end
  parser:parse({ vim.fn.line("w0") - 1, vim.fn.line("w$") - 1 })
  local node = ts.get_node({ bufnr = buf, ignore_injections = false })
  if not node then
    return
  end
  selections[buf] = { node }
  update_selection(buf, node)
end

---@param get_parent fun(node: TSNode): TSNode|nil
---@return fun(): nil
local function select_incremental(get_parent)
  return function()
    local buf = api.nvim_get_current_buf()
    local nodes = selections[buf]
    local csrow, cscol, cerow, cecol = visual_selection_range()

    if not nodes or #nodes == 0 or not range_matches_visual(nodes[#nodes], buf) then
      local ok, parser = pcall(ts.get_parser, buf)
      if not ok or not parser then
        return
      end
      parser:parse({ vim.fn.line("w0") - 1, vim.fn.line("w$") - 1 })
      local node = parser:named_node_for_range(
        { csrow - 1, cscol - 1, cerow - 1, cecol },
        { ignore_injections = false }
      )
      if not node then
        return
      end
      update_selection(buf, node)
      if nodes and #nodes > 0 then
        table.insert(selections[buf], node)
      else
        selections[buf] = { node }
      end
      return
    end

    local node = nodes[#nodes]
    while true do
      local parent = get_parent(node)
      if not parent or parent == node then
        local root_parser = assert(ts.get_parser(buf))
        root_parser:parse({ vim.fn.line("w0") - 1, vim.fn.line("w$") - 1 })
        local current_parser = root_parser:language_for_range({ csrow - 1, cscol - 1, cerow - 1, cecol })
        if root_parser == current_parser then
          node = root_parser:named_node_for_range({ csrow - 1, cscol - 1, cerow - 1, cecol })
          update_selection(buf, node)
          return
        end
        local parent_parser = current_parser:parent()
        parent = parent_parser:named_node_for_range({ csrow - 1, cscol - 1, cerow - 1, cecol })
      end
      node = parent
      local srow, scol, erow, ecol = get_vim_range(node, buf)
      local same_range = srow == csrow and scol == cscol and erow == cerow and ecol == cecol
      if not same_range then
        table.insert(selections[buf], node)
        if node ~= nodes[#nodes] then
          table.insert(nodes, node)
        end
        update_selection(buf, node)
        return
      end
    end
  end
end

M.node_incremental = select_incremental(function(node)
  return node:parent() or node
end)

function M.node_decremental()
  local buf = api.nvim_get_current_buf()
  local nodes = selections[buf]
  if not nodes or #nodes < 2 then
    return
  end
  table.remove(selections[buf])
  local node = nodes[#nodes - 1]
  update_selection(buf, node)
end

local DESC = {
  init_selection = "Start treesitter node selection",
  node_incremental = "Expand treesitter selection",
  node_decremental = "Shrink treesitter selection",
}

--- Buffer-local mappings (normal + visual) matching previous nvim-treesitter defaults.
function M.attach(bufnr)
  bufnr = bufnr or api.nvim_get_current_buf()
  vim.keymap.set("n", "<bs>", M.init_selection, { buffer = bufnr, silent = true, desc = DESC.init_selection })
  vim.keymap.set("x", "<bs>", M.node_incremental, { buffer = bufnr, silent = true, desc = DESC.node_incremental })
  vim.keymap.set("x", "<del>", M.node_decremental, { buffer = bufnr, silent = true, desc = DESC.node_decremental })
end

return M
