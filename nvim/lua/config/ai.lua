local M = {}

-- State management for AI terminal
local ai_state = {
  buf = nil,
  win = nil,
  job_id = nil,
  is_open = false,
}

-- Configuration
local config = {
  width = 0.8,
  height = 0.8,
  border = "rounded",
}

-- Get AI agent command from environment variable
local function get_ai_command()
  local ai_agent = vim.env.AI_AGENT
  if not ai_agent or ai_agent == "" then
    vim.notify("AI_AGENT environment variable is not set", vim.log.levels.ERROR, { title = "AI Module" })
    return nil
  end
  return ai_agent
end

-- Create floating window configuration
local function get_float_config()
  local width = math.floor(vim.o.columns * config.width)
  local height = math.floor(vim.o.lines * config.height)
  local col = math.floor((vim.o.columns - width) / 2)
  local row = math.floor((vim.o.lines - height) / 2)

  return {
    relative = "editor",
    width = width,
    height = height,
    col = col,
    row = row,
    style = "minimal",
    border = config.border,
    title = " AI Agent ",
    title_pos = "center",
  }
end

-- Create or get existing buffer
local function get_or_create_buffer()
  if ai_state.buf and vim.api.nvim_buf_is_valid(ai_state.buf) then
    return ai_state.buf
  end

  ai_state.buf = vim.api.nvim_create_buf(false, true)

  -- Set buffer options (buftype will be set automatically by jobstart with term=true)
  vim.bo[ai_state.buf].swapfile = false
  vim.bo[ai_state.buf].buflisted = false

  return ai_state.buf
end

-- Start AI agent in terminal
local function start_ai_agent(buf)
  local ai_command = get_ai_command()
  if not ai_command then
    return false
  end

  -- Use jobstart with term option instead of deprecated termopen
  vim.api.nvim_buf_call(buf, function()
    -- Start terminal job using jobstart (termopen replacement)
    ai_state.job_id = vim.fn.jobstart(ai_command, {
      term = true,
      on_exit = function(_, exit_code, _)
        ai_state.job_id = nil
        if exit_code ~= 0 then
          vim.notify(
            string.format("AI agent exited with code %d", exit_code),
            vim.log.levels.WARN,
            { title = "AI Module" }
          )
        end
      end,
    })
  end)

  if ai_state.job_id <= 0 then
    vim.notify("Failed to start AI agent", vim.log.levels.ERROR, { title = "AI Module" })
    return false
  end

  return true
end

-- Open AI window
local function open_ai_window()
  if ai_state.is_open and ai_state.win and vim.api.nvim_win_is_valid(ai_state.win) then
    return
  end

  local buf = get_or_create_buffer()
  if not buf then
    return
  end

  -- Start AI agent if not already running
  if not ai_state.job_id then
    if not start_ai_agent(buf) then
      return
    end
  end

  -- Create floating window
  local float_config = get_float_config()
  ai_state.win = vim.api.nvim_open_win(buf, true, float_config)

  -- Set window options using modern API
  vim.wo[ai_state.win].winhl = "Normal:Normal,FloatBorder:FloatBorder"

  -- Set up key mappings for the AI window
  local opts = { buffer = buf, nowait = true, silent = true }

  -- Go to normal mode with Escape in terminal mode
  vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", opts)

  -- Close window with Ctrl-A
  vim.keymap.set({ "t", "n" }, "<C-a>", function()
    M.toggle_ai_window()
  end, opts)

  -- Enter insert mode automatically in terminal
  vim.cmd("startinsert")

  ai_state.is_open = true
end

-- Close AI window
local function close_ai_window()
  if ai_state.win and vim.api.nvim_win_is_valid(ai_state.win) then
    vim.api.nvim_win_close(ai_state.win, false)
  end
  ai_state.win = nil
  ai_state.is_open = false
end

-- Toggle AI window
function M.toggle_ai_window()
  if ai_state.is_open then
    close_ai_window()
  else
    open_ai_window()
  end
end

-- Clean up function (optional, for manual cleanup)
function M.cleanup()
  close_ai_window()

  if ai_state.job_id then
    vim.fn.jobstop(ai_state.job_id)
    ai_state.job_id = nil
  end

  if ai_state.buf and vim.api.nvim_buf_is_valid(ai_state.buf) then
    vim.api.nvim_buf_delete(ai_state.buf, { force = true })
    ai_state.buf = nil
  end
end

-- Setup function (optional, for configuration)
function M.setup(opts)
  if opts then
    config = vim.tbl_deep_extend("force", config, opts)
  end
end

return M
