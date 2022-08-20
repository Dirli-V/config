local status_ok, which_key = pcall(require, "which-key")
if not status_ok then
  return
end

which_key.register({
  ["<A-j>"] = { ":move '>+1<CR>gv-gv", "Move text down" },
  ["<A-k>"] = { ":move '<-2<CR>gv-gv", "Move text up" },

  x = { "d", "Cut" },
}, { mode = "x" })
