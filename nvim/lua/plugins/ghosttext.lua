return {
  "raghur/vim-ghost",
  keys = {
    { "<leader>yg", "<cmd>GhostStart<cr>", desc = "Start GhostText" },
  },
  build = ":GhostInstall",
}
