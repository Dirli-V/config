require("nvim-treesitter-textobjects").setup({
  select = {
    lookahead = true,
  },
})

local sel = require("nvim-treesitter-textobjects.select")

local mappings = {
  { "af", "@function.outer", "outer function" },
  { "if", "@function.inner", nil },
  { "ac", "@class.outer", nil },
  { "ic", "@class.inner", nil },
  { "aa", "@parameter.outer", nil },
  { "ia", "@parameter.inner", nil },
  { "ab", "@block.outer", nil },
  { "ib", "@block.inner", nil },
  { "al", "@loop.outer", nil },
  { "il", "@loop.inner", nil },
  { "ai", "@conditional.outer", nil },
  { "ii", "@conditional.inner", nil },
}

for _, m in ipairs(mappings) do
  local key, query, desc = m[1], m[2], m[3]
  local opts = { silent = true }
  if desc then
    opts.desc = desc
  end
  vim.keymap.set({ "x", "o" }, key, function()
    sel.select_textobject(query, "textobjects")
  end, opts)
end
