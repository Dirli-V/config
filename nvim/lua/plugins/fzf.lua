return {
  "ibhagwan/fzf-lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  lazy = false,

  keys = {
    { "<leader>f", "<cmd>FzfLua files<cr>", desc = "Find Files (cwd)" },
    { "<leader>/", "<cmd>FzfLua grep search=<cr>", desc = "Grep (root dir)" },
    { "R", "<cmd>Fzf resume<cr>", desc = "Resume search" },
  },
  config = function()
    require("fzf-lua").setup({
      "telescope",
      fzf_opts = { ["--layout"] = "reverse" },
      winopts = {
        width = 0.95,
        height = 0.95,
      },
    })
  end,
}
