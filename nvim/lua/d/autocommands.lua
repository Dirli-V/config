local general_group = vim.api.nvim_create_augroup("_GeneralSettings", {})
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "qf", "help", "man", "lspinfo" },
  group = general_group,
  callback = function()
    vim.api.nvim_buf_set_keymap(0, "n", "q", ":close<CR>", { noremap = true })
  end
})
vim.api.nvim_create_autocmd("TextYankPost", {
  pattern = "*",
  group = general_group,
  callback = function()
    require('vim.highlight').on_yank({ higroup = 'Visual', timeout = 200 })
  end
})

local tabs_and_spaces_group = vim.api.nvim_create_augroup("_TabsAndSpaces", {})
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "lua", "javascript" },
  group = tabs_and_spaces_group,
  command = "set shiftwidth=2 tabstop=2"
})
vim.api.nvim_create_autocmd("FileType", {
  pattern = "java",
  group = tabs_and_spaces_group,
  command = "set autoindent noexpandtab tabstop=4 shiftwidth=4"
})

local git_group = vim.api.nvim_create_augroup("Git", {})
vim.api.nvim_create_autocmd("FileType", {
  pattern = "gitcommit",
  group = git_group,
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
        ticket .. ": "
      })
    end
  end
})
