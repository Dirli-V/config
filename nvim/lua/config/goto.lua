local M = {}

local goto_state = {
  highlights = {},
  word_map = {},
  namespace = vim.api.nvim_create_namespace("goto_mode"),
}

local shortcut_group = "GotoShortcut"
vim.api.nvim_set_hl(0, shortcut_group, {
  bg = "#111111",
  fg = "#e51a69",
  bold = true,
})

-- Generate shortcuts in a systematic pattern: aa, as, ad, af, aj, sa, ss, etc.
local function generate_shortcuts(word_count)
  local shortcuts = {}
  local letters = {
    "a",
    "s",
    "d",
    "f",
    "j",
    "k",
    "l",
    "g",
    "h",
    "q",
    "w",
    "e",
    "r",
    "t",
    "y",
    "u",
    "i",
    "o",
    "p",
    "z",
    "x",
    "c",
    "v",
    "b",
    "n",
    "m",
  }
  local shortcut_count = 0

  -- Generate all possible combinations
  for i = 1, #letters do
    for j = 1, #letters do
      if shortcut_count >= word_count then
        break
      end

      local shortcut = letters[i] .. letters[j]
      table.insert(shortcuts, shortcut)
      shortcut_count = shortcut_count + 1
    end

    if shortcut_count >= word_count then
      break
    end
  end

  return shortcuts
end

-- Scan a single buffer for words
local function scan_single_buffer(bufnr)
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local words = {}

  for line_num, line in ipairs(lines) do
    local pos = 1
    while pos <= #line do
      local word_start, word_end = string.find(line, "[%w]+", pos)
      if not word_start then
        break
      end

      -- Extract the actual word from the line
      local word = string.sub(line, word_start, word_end)

      table.insert(words, {
        word = word,
        bufnr = bufnr,
        line = line_num - 1, -- Convert to 0-based
        start_col = word_start - 1, -- Convert to 0-based
        end_col = word_end, -- Convert to 0-based
      })

      -- Move position past this word
      pos = word_end + 1
    end
  end

  return words
end

-- Scan visible buffers in current tab and create word map
local function scan_current_tab()
  local all_words = {}
  local word_count = 0

  -- Get all visible buffers in the current tab (visible windows)
  local visible_buffers = {}
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local win_config = vim.api.nvim_win_get_config(win)
    if win_config.relative ~= "" then -- Skip floating windows
      goto continue
    end
    local bufnr = vim.api.nvim_win_get_buf(win)
    if not visible_buffers[bufnr] then
      visible_buffers[bufnr] = true
      table.insert(visible_buffers, bufnr)
    end
    ::continue::
  end

  -- Scan each visible buffer in current tab
  for _, bufnr in ipairs(visible_buffers) do
    local buffer_words = scan_single_buffer(bufnr)
    for _, word_info in ipairs(buffer_words) do
      table.insert(all_words, word_info)
      word_count = word_count + 1
    end
  end

  -- Assign shortcuts in systematic pattern
  local shortcuts = generate_shortcuts(#all_words)
  local word_map = {}

  for i, word_info in ipairs(all_words) do
    table.insert(word_map, {
      word = word_info.word,
      shortcut = shortcuts[i],
      bufnr = word_info.bufnr,
      line = word_info.line,
      start_col = word_info.start_col,
      end_col = word_info.end_col,
    })
  end

  return word_map
end

-- Create highlights for words and shortcuts across multiple buffers
local function create_highlights(word_map)
  local highlights = {}

  for _, word_info in ipairs(word_map) do
    local bufnr = word_info.bufnr
    local line = word_info.line
    local start_col = word_info.start_col
    local shortcut = word_info.shortcut

    -- Add shortcut text overlay
    local shortcut_id = vim.api.nvim_buf_set_extmark(bufnr, goto_state.namespace, line, start_col, {
      virt_text = { { shortcut, shortcut_group } },
      virt_text_pos = "overlay",
      priority = 1001,
    })

    table.insert(highlights, {
      shortcut_id = shortcut_id,
      bufnr = bufnr,
      word_info = word_info,
    })
  end

  vim.cmd("redraw!")
  return highlights
end

-- Jump to a word based on shortcut
local function jump_to_word(shortcut)
  for _, highlight in ipairs(goto_state.highlights) do
    if highlight.word_info.shortcut == shortcut then
      local word_info = highlight.word_info
      local bufnr = word_info.bufnr

      -- Find the window that contains this buffer
      local target_win = nil
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        if vim.api.nvim_win_get_buf(win) == bufnr then
          target_win = win
          break
        end
      end

      if target_win then
        -- Switch to the window containing the target buffer
        vim.api.nvim_set_current_win(target_win)
        -- Set cursor position
        vim.api.nvim_win_set_cursor(target_win, { word_info.line + 1, word_info.start_col })
      else
        -- If no window found, switch to the buffer in current window
        vim.api.nvim_set_current_buf(bufnr)
        vim.api.nvim_win_set_cursor(0, { word_info.line + 1, word_info.start_col })
      end

      return true
    end
  end
  return false
end

-- Clean up highlights across all buffers
local function cleanup_highlights()
  if goto_state.highlights then
    for _, highlight in ipairs(goto_state.highlights) do
      vim.api.nvim_buf_del_extmark(highlight.bufnr, goto_state.namespace, highlight.shortcut_id)
    end
  end

  goto_state.highlights = {}
  goto_state.word_map = {}
end

-- Handle key input for goto mode
local function handle_goto_input()
  local input = vim.fn.getchar()
  ---@diagnostic disable-next-line: param-type-mismatch
  local char = vim.fn.nr2char(input)

  if char == "\27" then -- Escape key
    return
  end

  local shortcut = char

  local second_input = vim.fn.getchar()
  ---@diagnostic disable-next-line: param-type-mismatch
  local second_char = vim.fn.nr2char(second_input)
  if second_char == "\27" then -- Escape key
    return
  end
  shortcut = shortcut .. second_char

  jump_to_word(shortcut)
end

local function run_goto_mode()
  -- Clean up any existing highlights
  cleanup_highlights()

  -- Scan visible buffers in current tab and create word map
  goto_state.word_map = scan_current_tab()

  if #goto_state.word_map == 0 then
    vim.notify("No suitable words found in buffer", vim.log.levels.WARN)
    return
  end

  -- Create highlights
  goto_state.highlights = create_highlights(goto_state.word_map)

  -- Start input handling
  handle_goto_input()
end

-- Main goto function
function M.start_goto_mode()
  local _, err = pcall(run_goto_mode)
  if err then
    vim.notify("Goto mode failed: " .. err, vim.log.levels.ERROR)
  end
  cleanup_highlights()
end

-- Setup keybindings
function M.setup()
  vim.keymap.set("n", "s", M.start_goto_mode, { desc = "Start goto mode" })
end

-- Initialize the module
M.setup()

return M
