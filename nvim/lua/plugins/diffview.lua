return {
  "sindrets/diffview.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
  },
  keys = {
    { "<leader>gH", "<cmd>DiffviewFileHistory %<cr>", desc = "File History" },
    { "<leader>gt", "<cmd>DiffviewToggleFiles<cr>", desc = "Toggle File View" },
    {
      "<leader>gd",
      function()
        local branch = vim.fn.input("Diff with origin: ")
        vim.api.nvim_exec("!git fetch origin " .. branch, false)
        vim.api.nvim_command("DiffviewOpen origin/" .. branch)
      end,
      desc = "Diff with ...",
    },
    {
      "<leader>gD",
      function()
        vim.api.nvim_command("DiffviewOpen " .. vim.fn.input("Diff with: "))
      end,
      desc = "Diff with ...",
    },
  },
}
