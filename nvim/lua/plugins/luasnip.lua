return {
  "L3MON4D3/LuaSnip",
  opts = {
    updateevents = "TextChanged,TextChangedI",
  },
  keys = {
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
