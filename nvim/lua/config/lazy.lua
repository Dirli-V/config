local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  -- bootstrap lazy.nvim
  -- stylua: ignore
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(vim.env.LAZY or lazypath)

require("config.options")

local cwd = vim.fn.getcwd()
local lockfile
if cwd:sub(-#"/config") == "/config" then
  lockfile = cwd .. "/nvim/lazy-lock.json"
else
  lockfile = vim.fn.stdpath("config") .. "/lazy-lock.json"
end

require("lazy").setup({
  spec = {
    { import = "plugins" },
  },
  defaults = {
    lazy = true,
    version = "*",
  },
  lockfile = lockfile,
  checker = { enabled = false },
  change_detection = { enabled = false },
  performance = {
    rtp = {
      -- disable some rtp plugins
      disabled_plugins = {
        "gzip",
        "matchit",
        "matchparen",
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})

require("config.autocmds")
require("config.keymaps")

vim.filetype.add({
  filename = {
    ["Jenkinsfile"] = "groovy",
    [".kube/config"] = "yaml",
  },
})
