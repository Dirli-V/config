return {
  "folke/trouble.nvim",
  -- stylua: ignore
  keys = {
    { "<leader>q", "<cmd>TroubleToggle document_diagnostics<cr>", desc = "Document Diagnostics (Trouble)" },
    { "<c-j>", function() require("trouble").next({ skip_groups = true, jump = true }) end, desc = "Trouble next entry" },
    { "<c-k>", function() require("trouble").previous({ skip_groups = true, jump = true }) end, desc = "Trouble previous entry" },
    { "<c-q>", "<cmd>TroubleToggle quickfix<cr>", desc = "Quickfix List (Trouble)" },
  },
}
