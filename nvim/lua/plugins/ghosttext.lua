return {
  "raghur/vim-ghost",
  cmd = "GhostStart",
  keys = {
    { "<leader>yg", "<cmd>GhostStart<cr>", "Start GhostText" },
  },
  build = ":GhostInstall",
}
