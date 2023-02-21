-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

local function augroup(name)
  return vim.api.nvim_create_augroup("userspace_" .. name, { clear = true })
end

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
vim.api.nvim_create_autocmd("FileType", {
  pattern = "java",
  group = tabs_and_spaces_group,
  command = "set autoindent noexpandtab tabstop=4 shiftwidth=4",
})

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
