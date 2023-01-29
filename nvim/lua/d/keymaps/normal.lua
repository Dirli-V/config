local status_ok, which_key = pcall(require, "which-key")
if not status_ok then
  return
end

local trouble = require "trouble"
local dap = require "dap"
which_key.register({
  ["<C-p>"] = { "<cmd>Telescope find_files<cr>", "Find file" },

  ["<C-Up>"] = { ":resize -2<CR>", "Resize buffer h--" },
  ["<C-Down>"] = { ":resize +2<CR>", "Resize buffer h++" },
  ["<C-Left>"] = { ":vertical resize -2<CR>", "Resize buffer v--" },
  ["<C-Right>"] = { ":vertical resize +2<CR>", "Resize buffer v++" },

  L = { ":BufMRUPrev<CR>", "Previous buffer" },
  H = { ":BufMRUNext<CR>", "Next buffer" },

  J = { "mzJ`z", "Merge lines" },
  ["<C-d>"] = { "<C-d>zz", "Half-page down" },
  ["<C-u>"] = { "<C-u>zz", "Half-page up" },
  n = { "nzzzv", "Next match" },
  N = { "Nzzzv", "Previous match" },

  ["<A-j>"] = { "<Esc>:m .+1<CR>", "Move line down" },
  ["<A-k>"] = { "<Esc>:m .-2<CR>", "Move line up" },

  ["<esc>"] = { ":noh<return><esc>", "Clear search" },
  ["<esc>^["] = { "<esc>^[]]", "Clear search" },

  Y = { "y$", "Yank to end of line" },

  x = { "d", "Cut" },
  ["xx"] = { "dd", "Cut line" },
  X = { "D", "Cut to end of line" },

  ["gx"] = { ":!brave <cWORD><cr>", "Open URL" },

  ["<C-q>"] = { "<cmd>TroubleToggle quickfix<cr>", "Toggle quickfix list" },
  ["<C-j>"] = { function() trouble.next({ skip_groups = true, jump = true }) end, "Trouble next entry" },
  ["<C-k>"] = { function() trouble.previous({ skip_groups = true, jump = true }) end, "Trouble previous entry" },

  ["<C-f>"] = { require('telescope').extensions.live_grep_args.live_grep_args, "Find Text (rg)" },
  ["<C-s>"] = { ":wa<cr>", "Save all buffers" },

  ["<F5>"] = { dap.continue, "Continue" },
  ["<F10>"] = { dap.step_over, "Step over" },
  ["<F11>"] = { dap.step_into, "Step into" },
  ["<F12>"] = { dap.step_out, "Step out" },
}, {})

which_key.register({
  ["<CR>"] = { "ciw", "Change word" },
}, {
  noremap = false,
})

local harpoon_ui = require "harpoon.ui"
local harpoon_mark = require "harpoon.mark"
local neotest = require "neotest"
local gitsigns = require "gitsigns"
which_key.register({
  ["1"] = { function() harpoon_ui.nav_file(1) end, "Open harpoon file 1" },
  ["2"] = { function() harpoon_ui.nav_file(2) end, "Open harpoon file 2" },
  ["3"] = { function() harpoon_ui.nav_file(3) end, "Open harpoon file 3" },
  ["4"] = { function() harpoon_ui.nav_file(4) end, "Open harpoon file 4" },
  ["5"] = { function() harpoon_ui.nav_file(5) end, "Open harpoon file 5" },
  ["e"] = { "<cmd>NvimTreeToggle<cr>", "Explorer" },
  ["w"] = { "<cmd>w<CR>", "Save" },
  ["c"] = { "<cmd>Bdelete!<CR>", "Close Buffer" },
  ["b"] = { require 'dap'.toggle_breakpoint, "Toggle Breakpoint" },
  ["B"] = { function() require 'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))() end,
    "Conditional Breakpoint" },
  ["h"] = { harpoon_ui.toggle_quick_menu, "Toggle harpoon menu" },
  ["m"] = { harpoon_mark.add_file, "Add harpoon file" },
  ["q"] = { "<cmd>TroubleToggle document_diagnostics<cr>", "Toggle document diagnostics" },

  p = {
    name = "Packer",
    c = { "<cmd>PackerCompile<cr>", "Compile" },
    i = { "<cmd>PackerInstall<cr>", "Install" },
    s = { "<cmd>PackerSync<cr>", "Sync" },
    S = { "<cmd>PackerStatus<cr>", "Status" },
    u = { "<cmd>PackerUpdate<cr>", "Update" },
  },

  g = {
    name = "Git",
    j = { require 'gitsigns'.next_hunk, "Next Hunk" },
    k = { require 'gitsigns'.prev_hunk, "Prev Hunk" },
    l = { "<cmd>BlamerToggle<cr>", "Blame" },
    p = { require 'gitsigns'.preview_hunk, "Preview Hunk" },
    r = { require 'gitsigns'.reset_hunk, "Reset Hunk" },
    R = { require 'gitsigns'.reset_buffer, "Reset Buffer" },
    h = { require 'gitsigns'.stage_hunk, "Stage Hunk" },
    u = { require 'gitsigns'.undo_stage_hunk, "Undo Stage Hunk" },
    s = { "<cmd>Telescope git_status<cr>", "Status" },
    b = { "<cmd>Telescope git_branches<cr>", "Checkout branch" },
    c = { "<cmd>Telescope git_commits<cr>", "Checkout commit" },
    d = {
      "<cmd>Gitsigns diffthis HEAD<cr>",
      "Diff",
    },
  },

  l = {
    name = "LSP",
    w = { "<cmd>Telescope diagnostics<cr>", "Workspace Diagnostics" },
    i = { "<cmd>Mason<cr>", "Mason Installer" },
    u = { "<cmd>MasonToolsUpdate<cr>", "Mason Update All" },
    l = { "<cmd>MasonLog<cr>", "Mason Log" },
    S = { "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>", "Workspace Symbols" },
    I = { "<cmd>LspInfo<cr>", "LspInfo" },
  },

  d = {
    name = "Debug",
    r = { "<cmd>:lua require'dap'.repl.toggle()<CR>", "Repl Toggle" },
    l = { "<cmd>:lua require'dap'.run_last()<CR>", "Run Last" },
    d = { function() neotest.run.run(vim.fn.expand("%")) end, "Run tests in file" },
    j = { function() neotest.run.run({ strategy = "dap" }) end, "Run nearest test" },
    o = { function() neotest.output.open({ enter = true }) end, "Open test output" },
  },

  s = {
    name = "Search",
    C = { "<cmd>Telescope colorscheme<cr>", "Colorscheme" },
    h = { "<cmd>Telescope help_tags<cr>", "Find Help" },
    M = { "<cmd>Telescope man_pages<cr>", "Man Pages" },
    r = { "<cmd>Telescope oldfiles<cr>", "Open Recent File" },
    R = { "<cmd>Telescope registers<cr>", "Registers" },
    k = { "<cmd>Telescope keymaps<cr>", "Keymaps" },
    p = { "<cmd>Telescope git_files<cr>", "Git Files" },
    c = { "<cmd>Telescope commands<cr>", "Commands" },
    n = { "<cmd>Telescope notify<cr>", "Notifications" },
    t = { "<cmd>Telescope resume<cr>", "Resume search" },
    i = { "<cmd>Cheat<cr>", "Search cheat.sh" },
    f = { require('telescope').extensions.live_grep_args.live_grep_args, "Find Text (rg)" },
    F = { "<cmd>Telescope live_grep<CR>", "Find Text" },
    b = { function() require('telescope.builtin').buffers(require('telescope.themes').get_dropdown { previewer = false }) end,
      "Buffers" },
  },

  a = {
    name = "Gitsigns",
    s = { gitsigns.stage_hung, "Stage hunk" },
    r = { gitsigns.reset_hung, "Reset hunk" },
    S = { gitsigns.stage_buffer, "Stage buffer" },
    u = { gitsigns.undo_stage_hunk, "Undo stage buffer" },
    R = { gitsigns.reset_buffer, "Reset buffer" },
    p = { gitsigns.preview_hunk, "Preview hunk" },
    b = { function() gitsigns.blame_line { full = true } end, "Blame line" },
    B = { gitsigns.toggle_current_line_blame, "Toggle line blame" },
    d = { gitsigns.diffthis, "Diff this" },
    D = { function()
      local target = vim.fn.input("Diff with: ")
      if target == "" then
        target = "~"
      end
      gitsigns.diffthis(target)
    end, "Diff with" },
    e = { gitsigns.toggle_deleted, "Toggle deleted" },
  },

  y = {
    name = "Misc",
    r = { "<cmd>Telescope reloader<cr>", "Reload module" },
    a = { ":set rnu!<cr>", "Toggle relative line numbers" },
    l = { require('persistence').load, "Load session" },
    i = { "<cmd>LuaCacheProfile<cr>", "Impatient profile" },
    g = { "<cmd>GhostTextEnable<cr>", "GhostText enable" },
    c = { "<cmd>ComposerStart<cr>", "Start markdown composer" },
  },
}, {
  prefix = "<leader>",
})
