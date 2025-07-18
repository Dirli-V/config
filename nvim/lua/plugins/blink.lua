return {
  "Saghen/blink.cmp",
  lazy = false,
  opts = {
    keymap = {
      ["<C-e>"] = { "hide", "fallback" },
      ["<C-h>"] = { "accept" },

      ["<Up>"] = { "select_prev", "fallback" },
      ["<Down>"] = { "select_next", "fallback" },
      ["<C-p>"] = { "select_prev", "fallback" },
      ["<C-n>"] = { "select_next", "fallback" },

      ["<C-b>"] = { "scroll_documentation_up", "fallback" },
      ["<C-f>"] = { "scroll_documentation_down", "fallback" },
    },

    signature = {
      enabled = true,
    },

    completion = {
      documentation = {
        auto_show = true,
      },
    },
  },
}
