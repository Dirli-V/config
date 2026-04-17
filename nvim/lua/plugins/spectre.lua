vim.keymap.set("n", "<leader>sr", function()
  require("spectre").open()
end, { desc = "Replace in files (Spectre)" })
