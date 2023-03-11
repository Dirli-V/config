return {
  "L3MON4D3/LuaSnip",
  opts = {
    updateevents = "TextChanged,TextChangedI",
  },
  keys = {
    { "<tab>", false, mode = "i" },
    { "<tab>", false, mode = "s" },
    { "<s-tab>", false, mode = { "i", "s" } },
    {
      "<c-l>",
      function()
        local ls = require("luasnip")
        if ls.choice_active() then
          ls.choice_active(1)
          return
        end
        if ls.expandable() then
          ls.expand()
        end
      end,
      mode = { "i", "s" },
    },
    {
      "<c-j>",
      function()
        return require("luasnip").jumpable(1) and "<Plug>luasnip-jump-next" or "<tab>"
      end,
      expr = true,
      silent = true,
      mode = "i",
    },
    {
      "<c-j>",
      function()
        require("luasnip").jump(1)
      end,
      mode = "s",
    },
    {
      "<c-h>",
      function()
        require("luasnip").jump(-1)
      end,
      mode = { "i", "s" },
    },
  },
  config = function(_, opts)
    local types = require("luasnip.util.types")
    opts["ext_opts"] = {

      [types.choiceNode] = {
        active = {
          virt_text = { { "<-", "Error" } },
        },
      },
    }
    require("luasnip.loaders.from_lua").load({ paths = vim.fn.stdpath("config") .. "/lua/snippets" })
  end,
}
