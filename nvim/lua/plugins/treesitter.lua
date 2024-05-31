return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  event = { "BufReadPost", "BufNewFile" },
  dependencies = {
    "HiPhish/rainbow-delimiters.nvim",
    "JoosepAlviste/nvim-ts-context-commentstring",
    "nvim-treesitter/nvim-treesitter-textobjects",
    "nvim-treesitter/nvim-treesitter-context",
  },
  keys = {
    { "<bs>", desc = "Increment selection" },
    { "<del>", desc = "Decrement selection", mode = "x" },
  },
  opts = {
    ensure_installed = "all",
    highlight = {
      enable = true,
      disable = function(lang, bufnr)
        if vim.api.nvim_buf_line_count(bufnr) > 10000 then
          return true
        end
        if lang == "json" and #vim.api.nvim_buf_get_lines(bufnr, 0, 1, false)[1] > 10000 then
          return true
        end
        return false
      end,
    },
    indent = { enable = true },
    rainbow = {
      enable = true,
    },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = "<bs>",
        node_incremental = "<bs>",
        scope_incremental = false,
        node_decremental = "<del>",
      },
    },
  },
  config = function(_, opts)
    require("nvim-treesitter.configs").setup(opts)
    require("treesitter-context").setup()
    require("ts_context_commentstring").setup({
      enable_autocmd = false,
    })
  end,
}
