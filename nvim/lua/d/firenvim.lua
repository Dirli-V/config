if not vim.g["started_by_firenvim"] then
  return
end

local blacklistedSites = { ".*twitter\\.com.*" }

local localSettings = {
  [".*"] = {
    cmdline = "firenvim",
  },
  [".*jira.*"] = {
    content = "html",
    selector = "#tinymce",
  },
}
for _, site in pairs(blacklistedSites) do
  localSettings[site] = { takeover = "never" }
end

vim.g.firenvim_config = {
  localSettings = localSettings
}

vim.opt.laststatus = 0
vim.opt.showtabline = 0
vim.opt.signcolumn = "no"
vim.opt.number = false
vim.opt.relativenumber = false

vim.cmd [[
  augroup _firenvim_filetype
    autocmd!
    au BufEnter github.com_*.txt set filetype=markdown
  augroup end
]]
