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

-- Scan a single window for words (only visible lines)
local function scan_single_window(win, bufnr, first_line, last_line)
  local lines = vim.api.nvim_buf_get_lines(bufnr, first_line, last_line + 1, false)
  local words = {}

  for i, line in ipairs(lines) do
    local line_num = first_line + i
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
        win = win,
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
  local current_win = vim.api.nvim_get_current_win()

  -- Get all visible windows in the current tab with their visible line ranges
  local windows_info = {}
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local win_config = vim.api.nvim_win_get_config(win)
    if win_config.relative ~= "" then -- Skip floating windows
      goto continue
    end
    local bufnr = vim.api.nvim_win_get_buf(win)
    local first_line = vim.fn.line("w0", win) - 1 -- Convert to 0-based
    local last_line = vim.fn.line("w$", win) - 1  -- Convert to 0-based
    local info = { win = win, bufnr = bufnr, first_line = first_line, last_line = last_line }
    -- Insert current window at front so it gets priority for overlapping positions
    if win == current_win then
      table.insert(windows_info, 1, info)
    else
      table.insert(windows_info, info)
    end
    ::continue::
  end

  -- Track which buffer positions already have shortcuts (to handle same buffer in multiple windows)
  local seen_positions = {}

  -- Scan each visible window's visible lines
  for _, info in ipairs(windows_info) do
    local window_words = scan_single_window(info.win, info.bufnr, info.first_line, info.last_line)
    for _, word_info in ipairs(window_words) do
      -- Create unique key for this position in the buffer
      local pos_key = string.format("%d:%d:%d", word_info.bufnr, word_info.line, word_info.start_col)
      if not seen_positions[pos_key] then
        seen_positions[pos_key] = true
        table.insert(all_words, word_info)
        word_count = word_count + 1
      end
    end
  end

  -- Assign shortcuts in systematic pattern
  local shortcuts = generate_shortcuts(#all_words)
  local word_map = {}

  for i, word_info in ipairs(all_words) do
    table.insert(word_map, {
      word = word_info.word,
      shortcut = shortcuts[i],
      win = word_info.win,
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
      local target_win = word_info.win

      local jump_cmd = ("normal! %dG%d|"):format(word_info.line + 1, word_info.start_col + 1)

      if vim.api.nvim_win_is_valid(target_win) then
        -- Switch to the specific window and jump using normal mode to update jumplist
        vim.api.nvim_set_current_win(target_win)
        vim.cmd(jump_cmd)
      else
        -- Fallback: if window is no longer valid, use buffer in current window
        vim.api.nvim_set_current_buf(word_info.bufnr)
        vim.cmd(jump_cmd)
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
