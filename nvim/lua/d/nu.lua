local status_ok, nu = pcall(require, "nu")
if not status_ok then
  return
end
nu.setup{}
