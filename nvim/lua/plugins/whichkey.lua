return {
  "folke/which-key.nvim",
  config = function(_, opts)
    local wk = require("which-key")
    wk.setup(opts)
    wk.register({
      mode = { "n", "v" },
      ["g"] = { name = "+goto" },
      ["gz"] = { name = "+surround" },
      ["]"] = { name = "+next" },
      ["["] = { name = "+prev" },
      ["<leader><tab>"] = { name = "+tabs" },
      ["<leader>b"] = { name = "+buffer" },
      ["<leader>c"] = { name = "+code" },
      ["<leader>g"] = { name = "+git" },
      ["<leader>gh"] = { name = "+hunks" },
      ["<leader>s"] = { name = "+search" },
      ["<leader>d"] = { name = "+debug" },
      ["<leader>sn"] = { name = "+noice" },
      ["<leader>u"] = { name = "+ui" },
      ["<leader>x"] = { name = "+diagnostics/quickfix" },
      ["<leader>n"] = { name = "+note" },
      ["<leader>y"] = { name = "+misc" },
    })
  end,
}
