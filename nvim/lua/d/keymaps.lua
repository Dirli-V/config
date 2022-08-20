vim.api.nvim_set_keymap("", "<Space>", "<Nop>", { noremap = true, silent = true })
vim.g.mapleader = " "
vim.g.maplocalleader = " "

require "d.keymaps.normal"
require "d.keymaps.insert"
require "d.keymaps.visual"
require "d.keymaps.visual_block"
