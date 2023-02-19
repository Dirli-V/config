local function call_and_append_if_is_executable(tbl, fn, cmd)
  if vim.fn.executable(cmd) == 1 then
    table.insert(tbl, fn())
  end
end

return {
  "jose-elias-alvarez/null-ls.nvim",
  opts = function()
    local nls = require("null-ls")

    local sources = {}
    call_and_append_if_is_executable(sources, function()
      return nls.builtins.formatting.stylua
    end, "stylua")
    call_and_append_if_is_executable(sources, function()
      return nls.builtins.diagnostics.black
    end, "black")

    return {
      sources = sources,
    }
  end,
}
