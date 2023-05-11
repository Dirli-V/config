return {
  "lukas-reineke/indent-blankline.nvim",
  event = { "BufReadPost", "BufNewFile", "VeryLazy" },
  opts = {
    char = "▏",
    filetype_exclude = { "help", "neo-tree", "Trouble", "lazy", "mason" },
    show_trailing_blankline_indent = false,
    show_current_context = false,
  },
}
