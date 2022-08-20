local status_ok, persistence = pcall(require, "persistence")
if not status_ok then
  return
end

if #vim.fn.argv() == 0 then
  persistence.setup {}
  vim.schedule(function() persistence.load() end)
end
