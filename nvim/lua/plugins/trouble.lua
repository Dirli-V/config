local Util = require("lazy.core.util")

local next_entry = function()
  if require("trouble").is_open() then
    require("trouble").next({ skip_groups = true, jump = true })
  else
    local success = pcall(vim.cmd.cnext)
    if not success then
      Util.info("End of list. Going to first.", { title = "Quickfix" })
      vim.cmd.crewind()
    end
  end
end

local previous_entry = function()
  if require("trouble").is_open() then
    require("trouble").previous({ skip_groups = true, jump = true })
  else
    local success = pcall(vim.cmd.cprev)
    if not success then
      Util.info("Start of list. Going to last.", { title = "Quickfix" })
      vim.cmd.clast()
    end
  end
end

return {
  "folke/trouble.nvim",
  cmd = { "TroubleToggle", "Trouble" },
  opts = { use_diagnostic_signs = true },
  keys = {
    { "<leader>xx", "<cmd>TroubleToggle document_diagnostics<cr>", desc = "Document Diagnostics (Trouble)" },
    { "<leader>xX", "<cmd>TroubleToggle workspace_diagnostics<cr>", desc = "Workspace Diagnostics (Trouble)" },
    { "<leader>xL", "<cmd>TroubleToggle loclist<cr>", desc = "Location List (Trouble)" },
    { "<leader>xQ", "<cmd>TroubleToggle quickfix<cr>", desc = "Quickfix List (Trouble)" },
    {
      "[q",
      previous_entry,
      desc = "Previous trouble/quickfix item",
    },
    {
      "]q",
      next_entry,
      desc = "Next trouble/quickfix item",
    },
    { "<leader>q", "<cmd>TroubleToggle document_diagnostics<cr>", desc = "Document Diagnostics (Trouble)" },
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
    { "<c-q>", "<cmd>TroubleToggle quickfix<cr>", desc = "Quickfix List (Trouble)" },
  },
}
