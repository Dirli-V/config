local next_entry = function()
  if require("trouble").is_open() then
    require("trouble").next({ skip_groups = true, jump = true })
  else
    local success = pcall(vim.cmd.cnext)
    if not success then
      local not_empty = pcall(vim.cmd.crewind)
      if not_empty then
        vim.notify("End of list. Going to first.", vim.log.levels.INFO, { title = "Quickfix" })
      end
    end
  end
end

local previous_entry = function()
  if require("trouble").is_open() then
    require("trouble").prev({ skip_groups = true, jump = true })
  else
    local success = pcall(vim.cmd.cprev)
    if not success then
      local not_empty = pcall(vim.cmd.clast)
      if not_empty then
        vim.notify("Start of list. Going to last.", vim.log.levels.INFO, { title = "Quickfix" })
      end
    end
  end
end

require("trouble").setup({
  picker = {
    actions = require("trouble.sources.snacks").actions,
    win = {
      input = {
        keys = {
          ["<c-t>"] = { "trouble_open", mode = { "n", "i" } },
        },
      },
    },
  },
})

vim.keymap.set("n", "<leader>q", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Open diagnostics (Trouble)" })
vim.keymap.set("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Open diagnostics (Trouble)" })
vim.keymap.set("n", "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", { desc = "Open local diagnostics (Trouble)" })
vim.keymap.set("n", "<c-j>", next_entry, { desc = "Trouble next entry" })
vim.keymap.set("n", "<c-k>", previous_entry, { desc = "Trouble previous entry" })
vim.keymap.set("n", "<c-q>", "<cmd>Trouble quickfix toggle<cr>", { desc = "Quickfix List (Trouble)" })
