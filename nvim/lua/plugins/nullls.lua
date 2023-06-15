local function call_and_append_if_is_executable(tbl, fn, cmd)
  if vim.fn.executable(cmd) == 1 then
    table.insert(tbl, fn())
  end
end

return {
  "jose-elias-alvarez/null-ls.nvim",
  event = "BufNew",
  opts = function()
    local nls = require("null-ls")

    local sources = {}
    call_and_append_if_is_executable(sources, function()
      return nls.builtins.formatting.stylua
    end, "stylua")
    call_and_append_if_is_executable(sources, function()
      return nls.builtins.formatting.black
    end, "black")
    call_and_append_if_is_executable(sources, function()
      return nls.builtins.formatting.fixjson
    end, "fixjson")
    call_and_append_if_is_executable(sources, function()
      return nls.builtins.formatting.alejandra
    end, "alejandra")
    call_and_append_if_is_executable(sources, function()
      return nls.builtins.diagnostics.deadnix
    end, "deadnix")
    call_and_append_if_is_executable(sources, function()
      return nls.builtins.code_actions.statix
    end, "statix")
    call_and_append_if_is_executable(sources, function()
      return nls.builtins.formatting.prettierd
    end, "prettierd")

    return {
      sources = sources,
    }
  end,
}
