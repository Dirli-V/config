return {
  "ggandor/leap.nvim",
  keys = {
    { "s", mode = { "n", "x", "o" }, desc = "Leap forward to" },
    { "S", mode = { "n", "x", "o" }, desc = "Leap backward to" },
    { "gs", mode = { "n", "x", "o" }, desc = "Leap cross window" },
  },
  config = function(_, opts)
    local leap = require("leap")
    for k, v in pairs(opts) do
      leap.opts[k] = v
    end
    for _, _1_ in ipairs({
      { { "n", "x", "o" }, "s", "<Plug>(leap-forward-to)", "Leap forward to" },
      { { "n", "x", "o" }, "S", "<Plug>(leap-backward-to)", "Leap backward to" },
      { { "n", "x", "o" }, "gs", "<Plug>(leap-cross-window)", "Leap cross window" },
    }) do
      local _each_2_ = _1_
      local modes = _each_2_[1]
      local lhs = _each_2_[2]
      local rhs = _each_2_[3]
      local desc = _each_2_[4]
      for _, mode in ipairs(modes) do
        if vim.fn.hasmapto(rhs, mode) == 0 then
          vim.keymap.set(mode, lhs, rhs, { silent = true, desc = desc })
        else
        end
      end
    end
  end,
}
