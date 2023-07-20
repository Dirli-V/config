local function augroup(name)
  return vim.api.nvim_create_augroup("userspace_" .. name, { clear = true })
end

-- Check if we need to reload the file when it changed
vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  group = augroup("checktime"),
  command = "checktime",
})

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup("highlight_yank"),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- resize splits if window got resized
vim.api.nvim_create_autocmd({ "VimResized" }, {
  group = augroup("resize_splits"),
  callback = function()
    vim.cmd("tabdo wincmd =")
  end,
})

-- go to last loc when opening a buffer
vim.api.nvim_create_autocmd("BufReadPost", {
  group = augroup("last_loc"),
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- close some filetypes with <q>
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("close_with_q"),
  pattern = {
    "PlenaryTestPopup",
    "help",
    "lspinfo",
    "man",
    "notify",
    "qf",
    "spectre_panel",
    "startuptime",
    "tsplayground",
    "checkhealth",
    "neotest-output",
    "symboltree",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
  end,
})

-- wrap and check for spell in text filetypes
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("wrap_spell"),
  pattern = { "gitcommit", "markdown" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
})

-- Auto create dir when saving a file, in case some intermediate directory does not exist
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
  group = augroup("auto_create_dir"),
  callback = function(event)
    if event.match:match("^%w%w+://") then
      return
    end
    local file = vim.loop.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "gitcommit",
  group = augroup("add_ticket_id"),
  callback = function()
    local lines = vim.api.nvim_buf_get_lines(0, 4, 5, true)
    for _, line in ipairs(lines) do
      local start_index = string.find(line, "/", 1, true)
      if not start_index then
        return
      end
      start_index = start_index + 1
      local first_dash = string.find(line, "-", start_index, true) + 1
      if not first_dash then
        return
      end
      local end_index = string.find(line, "-", first_dash, true)
      local ticket = ""
      if end_index then
        ticket = string.sub(line, start_index, end_index - 1)
      else
        ticket = string.sub(line, start_index)
      end
      vim.api.nvim_buf_set_lines(0, 0, 1, true, {
        ticket .. ": ",
      })
    end
  end,
})

local tabs_and_spaces_group = augroup("tabs_and_spaces")
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "lua", "javascript", "typescriptreact", "typescript", "nix" },
  group = tabs_and_spaces_group,
  command = "set shiftwidth=2 tabstop=2",
})
-- vim.api.nvim_create_autocmd("FileType", {
--   pattern = "java",
--   group = tabs_and_spaces_group,
--   command = "set autoindent noexpandtab tabstop=4 shiftwidth=4",
-- })

vim.api.nvim_create_autocmd("User", {
  pattern = "vim-ghost#connected",
  group = augroup("ghost_text"),
  command = "set ft=markdown",
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "qf",
  group = augroup("open_trouble_on_qf"),
  callback = function()
    vim.schedule(function()
      vim.cmd("cclose")
      vim.cmd("Trouble quickfix")
    end)
  end,
})
