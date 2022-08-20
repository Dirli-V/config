local status_ok, which_key = pcall(require, "which-key")
if not status_ok then
  return
end

which_key.register({
  ["<"] = { "<gv", "Decrease indent" },
  [">"] = { ">gv", "Increase indent" },

  ["<A-j>"] = { ":m .+1<CR>==", "Move text down" },
  ["<A-k>"] = { ":m .-2<CR>==", "Move text up" },

  p = { '"_dP', "Paste" }
}, { mode = "v" })

which_key.register({
  g = {
    name = "Git",
    l = { "<cmd>BlamerToggle<cr>", "Blame" },
  },
}, {
  mode = "v",
  prefix = "<leader>",
})
