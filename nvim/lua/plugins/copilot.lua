local enabled = true
local toggle = function()
  if enabled then
    vim.cmd("Copilot disable")
    enabled = false
  else
    vim.cmd("Copilot enable")
    enabled = true
  end
end

vim.keymap.set("n", "<C-l>", toggle, { desc = "Toggle Copilot" })
vim.keymap.set("i", "<C-l>", 'copilot#Accept("\\<CR>")', {
  expr = true,
  replace_keycodes = false,
})
vim.g.copilot_no_tab_map = true
