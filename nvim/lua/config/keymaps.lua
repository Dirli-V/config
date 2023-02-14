-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

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
map({ "n", "x" }, "x", "d")
map({ "n", "x" }, "X", "D")
map("n", "xx", "dd")
