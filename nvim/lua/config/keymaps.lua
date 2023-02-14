-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local function map(mode, lhs, rhs, opts)
  local keys = require("lazy.core.handler").handlers.keys
  ---@cast keys LazyKeysHandler
  -- do not create the keymap if a lazy keys handler exists
  if not keys.active[keys.parse({ lhs, mode = mode }).id] then
    opts = opts or {}
    opts.silent = opts.silent ~= false
    vim.keymap.set(mode, lhs, rhs, opts)
  end
end

map("n", "<leader>ww", "<nop>")
map("n", "<leader>wd", "<nop>")
map("n", "<leader>w-", "<nop>")
map("n", "<leader>w|", "<nop>")

map("n", "<cr>", "ciw", { desc = "Change inner word" })
map("n", "<leader>w", "<cmd>w<cr>", { desc = "Safe file" })
map("n", "<leader>W", "<cmd>wa<cr>", { desc = "Safe all files" })
