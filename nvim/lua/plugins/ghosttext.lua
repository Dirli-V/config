return {
  "raghur/vim-ghost",
  cmd = "GhostStart",
  keys = {
    { "<leader>yg", "<cmd>GhostStart<cr>", desc = "Start GhostText" },
  },
  build = ":GhostInstall",
}
