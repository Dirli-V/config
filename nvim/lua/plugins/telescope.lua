local Util = require("lazyvim.util")

return {
  "telescope.nvim",
  dependencies = {
    "nvim-telescope/telescope-fzf-native.nvim",
    build = "make",
    config = function()
      require("telescope").load_extension("fzf")
    end,
  },
  keys = {
    { "<leader>F", Util.telescope("files"), desc = "Find Files (root dir)" },
    { "<leader>f", Util.telescope("files", { cwd = false }), desc = "Find Files (cwd)" },
    { "R", "<cmd>Telescope resume<cr>", desc = "Resume search" },
    { "<leader>ff", false },
    { "<leader>fF", false },
    { "<leader>fb", false },
    { "<leader>fr", false },
  },
}
