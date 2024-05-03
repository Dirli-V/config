return {
  "cbochs/grapple.nvim",
  opts = {
    scope = "git",
  },
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  cmd = "Grapple",
  keys = {
    {
      "<leader>m",
      "<cmd>Grapple toggle<cr>",
      desc = "Mark file",
    },
    {
      "<leader>h",
      "<cmd>Grapple toggle_tags<cr>",
      desc = "Toggle mark menu",
    },
    {
      "<a-a>",
      "<cmd>Grapple select index=1<cr>",
      desc = "Nav to file 1",
    },
    {
      "<a-s>",
      "<cmd>Grapple select index=2<cr>",
      desc = "Nav to file 2",
    },
    {
      "<a-d>",
      "<cmd>Grapple select index=3<cr>",
      desc = "Nav to file 3",
    },
    {
      "<a-f>",
      "<cmd>Grapple select index=4<cr>",
      desc = "Nav to file 4",
    },
    {
      "<a-g>",
      "<cmd>Grapple select index=5<cr>",
      desc = "Nav to file 5",
    },
  },
}
