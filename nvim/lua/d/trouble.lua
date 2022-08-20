local status_ok, trouble = pcall(require, "trouble")
if not status_ok then
  return
end

trouble.setup {}

vim.api.nvim_create_autocmd("FileType", {
  pattern = "qf",
  callback = function()
    vim.schedule(function()
      vim.cmd "cclose"
      vim.cmd "Trouble quickfix"
    end)
  end,
})
