local nvim_ts = require("nvim-treesitter")
nvim_ts.setup()
assert(
  nvim_ts.install,
  "neovim-treesitter/nvim-treesitter is required (top-level install()). "
    .. "Run :lua vim.pack.update() or remove ~/.local/share/nvim/site/pack/core/opt/nvim-treesitter and restart."
)

local parsers = {
  "angular",
  "asm",
  "bash",
  "c",
  "c_sharp",
  "capnp",
  "cmake",
  "comment",
  "cpp",
  "css",
  "csv",
  "diff",
  "dockerfile",
  "git_config",
  "git_rebase",
  "gitattributes",
  "gitcommit",
  "gitignore",
  "glsl",
  "go",
  "gomod",
  "gpg",
  "groovy",
  "helm",
  "html",
  "java",
  "javascript",
  "json",
  "json5",
  "just",
  "kotlin",
  "lua",
  "luadoc",
  "make",
  "markdown",
  "markdown_inline",
  "nix",
  "nu",
  "php",
  "proto",
  "python",
  "rust",
  "scss",
  "terraform",
  "textproto",
  "toml",
  "tsx",
  "typescript",
  "vim",
  "vimdoc",
  "wgsl",
  "wgsl_bevy",
  "xml",
  "yaml",
}

nvim_ts.install(parsers)

local ok_rd, rainbow_delimiters = pcall(require, "rainbow-delimiters")
if ok_rd then
  vim.g.rainbow_delimiters = {
    strategy = {
      [""] = rainbow_delimiters.strategy["global"],
    },
    query = {
      [""] = "rainbow-delimiters",
    },
  }
end

local inc = require("config.treesitter_incremental")

local function should_skip_treesitter(buf)
  if vim.bo[buf].buftype ~= "" then
    return true
  end
  if vim.api.nvim_buf_line_count(buf) > 10000 then
    return true
  end
  if vim.bo[buf].filetype == "json" then
    local line0 = vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] or ""
    if #line0 > 10000 then
      return true
    end
  end
  return false
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = "*",
  callback = function(args)
    local buf = args.buf
    if should_skip_treesitter(buf) then
      return
    end
    if not vim.treesitter.language.get_lang(vim.bo[buf].filetype) then
      return
    end
    local ok = pcall(vim.treesitter.start, buf)
    if not ok then
      return
    end
    vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
    vim.wo.foldmethod = "expr"
    vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"

    inc.attach(buf)
  end,
})

require("treesitter-context").setup({ max_lines = 3 })
require("ts_context_commentstring").setup({ enable_autocmd = false })

vim.keymap.set("n", "<leader>ux", "<cmd>TSContextToggle<cr>", { desc = "Toggle TS context" })
