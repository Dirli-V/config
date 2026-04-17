require("nvim-treesitter.configs").setup({
  ensure_installed = {
    "angular", "asm", "bash", "c", "c_sharp", "capnp", "cmake", "comment",
    "cpp", "css", "csv", "diff", "dockerfile", "git_config", "git_rebase",
    "gitattributes", "gitcommit", "gitignore", "glsl", "go", "gomod", "gpg",
    "groovy", "helm", "html", "java", "javascript", "json", "json5", "just",
    "kotlin", "lua", "luadoc", "make", "markdown", "markdown_inline", "nix",
    "nu", "php", "proto", "python", "rust", "scss", "terraform", "textproto",
    "toml", "tsx", "typescript", "vim", "vimdoc", "wgsl", "wgsl_bevy", "xml",
    "yaml",
  },
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
  rainbow = { enable = true },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = "<bs>",
      node_incremental = "<bs>",
      scope_incremental = false,
      node_decremental = "<del>",
    },
  },
})

require("treesitter-context").setup({ max_lines = 3 })
require("ts_context_commentstring").setup({ enable_autocmd = false })

vim.keymap.set("n", "<leader>ux", "<cmd>TSContextToggle<cr>", { desc = "Toggle TS context" })
