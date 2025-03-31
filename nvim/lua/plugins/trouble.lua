local Util = require("lazy.core.util")

local next_entry = function()
  if require("trouble").is_open() then
    require("trouble").next({ skip_groups = true, jump = true })
  else
    local success = pcall(vim.cmd.cnext)
    if not success then
      local not_empty = pcall(vim.cmd.crewind)
      if not_empty then
        Util.info("End of list. Going to first.", { title = "Quickfix" })
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
        Util.info("Start of list. Going to last.", { title = "Quickfix" })
      end
    end
  end
end

return {
  "folke/trouble.nvim",
  cmd = { "Trouble" },
  opts = function(_, opts)
    return vim.tbl_deep_extend("force", opts or {}, {
      picker = {
        actions = require("trouble.sources.snacks").actions,
        win = {
          input = {
            keys = {
              ["<c-t>"] = {
                "trouble_open",
                mode = { "n", "i" },
              },
            },
          },
        },
      },
    })
  end,
  keys = {
    {
      "<leader>q",
      "<cmd>Trouble diagnostics toggle<cr>",
      desc = "Open diagnostics (Trouble)",
    },
    {
      "<leader>xx",
      "<cmd>Trouble diagnostics toggle<cr>",
      desc = "Open diagnostics (Trouble)",
    },
    { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Open local diagnostics (Trouble)" },
    {
      "<c-j>",
      next_entry,
      desc = "Trouble next entry",
    },
    {
      "<c-k>",
      previous_entry,
      desc = "Trouble previous entry",
    },
    { "<c-q>", "<cmd>Trouble quickfix toggle<cr>", desc = "Quickfix List (Trouble)" },
  },
}
