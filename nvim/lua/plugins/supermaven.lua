local env = os.getenv("USE_AI_TOOLS")
if env == nil or env == "" then
  return {}
end

return {
  "supermaven-inc/supermaven-nvim",
  event = "VeryLazy",
  opts = {
    keymaps = {
      accept_suggestion = "<C-l>",
      clear_suggestion = "<C-o>",
      accept_word = "<C-h>",
    },
  },
  config = function(_, opts)
    require("supermaven-nvim").setup(opts)
  end,
}
