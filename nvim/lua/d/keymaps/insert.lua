local status_ok, which_key = pcall(require, "which-key")
if not status_ok then
  return
end

which_key.register({
  [","] = { ",<c-g>u", "Insert undo break point" },
  ["."] = { ".<c-g>u", "Insert undo break point" },
  ["?"] = { "?<c-g>u", "Insert undo break point" },
  ["!"] = { "!<c-g>u", "Insert undo break point" },
  [")"] = { ")<c-g>u", "Insert undo break point" },
}, { mode = "i" })
