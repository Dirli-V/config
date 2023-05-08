-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local helpers = require("helpers")

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
map("n", "<leader>fn", "<nop>")
map("n", "<leader>gg", "<nop>")
map("n", "<leader>gG", "<nop>")
map("n", "<leader>qq", "<nop>")
map("n", "<leader>ft", "<nop>")
map("n", "<leader>fT", "<nop>")
map("n", "<leader>fR", "<nop>")

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

map({ "i", "v", "n", "s" }, "<C-s>", "<cmd>wa<cr><esc>", { desc = "Save all file" })

map("n", "<leader>yy", "", {
  desc = "Copy URL of open file",
  callback = function()
    helpers.copy_git_file_to_clipboard(false)
  end,
})
map("n", "<leader>yY", "", {
  desc = "Copy URL of open file (+ line number)",
  callback = function()
    helpers.copy_git_file_to_clipboard(true)
  end,
})

local bufnr_to_node_history = {}
map("n", "<c-l>", "", {
  desc = "Select TS node under cursor",
  callback = function()
    local node = helpers.get_treesitter_node_under_cursor()
    bufnr_to_node_history[vim.api.nvim_get_current_buf()] = { node }
    helpers.select_tresssitter_node(node, false)
  end,
})
map("x", "<c-l>", "", {
  desc = "Expand selection to parent TS node",
  callback = function()
    local bufnr = vim.api.nvim_get_current_buf()
    if bufnr_to_node_history[bufnr] == nil then
      local node = helpers.get_treesitter_node_under_cursor()
      bufnr_to_node_history[bufnr] = { node }
    else
      local parent = bufnr_to_node_history[bufnr][#bufnr_to_node_history[bufnr]]:parent()
      table.insert(bufnr_to_node_history[bufnr], parent)
    end
    helpers.select_tresssitter_node(bufnr_to_node_history[bufnr][#bufnr_to_node_history[bufnr]], true)
  end,
})
map("x", "<c-h>", "", {
  desc = "Reduce selection to inner TS node",
  callback = function()
    local bufnr = vim.api.nvim_get_current_buf()
    if bufnr_to_node_history[bufnr] ~= nil and #bufnr_to_node_history[bufnr] >= 2 then
      table.remove(bufnr_to_node_history[bufnr])
      helpers.select_tresssitter_node(bufnr_to_node_history[bufnr][#bufnr_to_node_history[bufnr]], true)
    end
  end,
})
