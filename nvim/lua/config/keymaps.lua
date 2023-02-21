-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.g.maplocalleader = ","

local function map(mode, lhs, rhs, opts)
  opts = opts or {}
  opts.silent = opts.silent ~= false
  opts.remap = opts.remap or false
  vim.keymap.set(mode, lhs, rhs, opts)
end

map("n", "<leader>ww", "<nop>")
map("n", "<leader>wd", "<nop>")
map("n", "<leader>w-", "<nop>")
map("n", "<leader>w|", "<nop>")

map("n", "<cr>", "ciw", { desc = "Change inner word", remap = true })
map("n", "<leader>w", "<cmd>w<cr>", { desc = "Safe file" })
map("n", "<leader>W", "<cmd>wa<cr>", { desc = "Safe all files" })

map({ "n", "x" }, "d", '"_d')
map("n", "dd", '"_dd')
map({ "n", "x" }, "D", '"_D')
map({ "n", "x" }, "c", '"_c')
map("n", "cc", '"_cc')
map({ "n", "x" }, "C", '"_C')
map("n", "x", "d")
map("n", "X", "D")
map("n", "xx", "dd")
map("x", "p", '"_dP')

map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")

map("n", "gh", "<c-w>h", { desc = "Go to left window" })
map("n", "gl", "<c-w>l", { desc = "Go to right window" })
map("n", "gj", "<c-w>j", { desc = "Go to down window" })
map("n", "gk", "<c-w>k", { desc = "Go to up window" })

map("n", "<leader>yy", "", {
  desc = "Copy URL of open file",
  callback = function()
    require("helpers").copy_git_file_to_clipboard(false)
  end,
})
map("n", "<leader>yY", "", {
  desc = "Copy URL of open file (+ line number)",
  callback = function()
    require("helpers").copy_git_file_to_clipboard(true)
  end,
})
