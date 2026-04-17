local env = os.getenv("USE_AI_TOOLS")
if env == nil or env == "" then
  return
end

require("supermaven-nvim").setup({
  keymaps = {
    accept_suggestion = "<C-l>",
    clear_suggestion = "<C-o>",
    accept_word = "<C-j>",
  },
})
