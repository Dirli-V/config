local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

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
  pattern = {
    [".*"] = {
      function(path, buf)
        -- Adaptation of https://github.com/folke/snacks.nvim/blob/main/lua/snacks/bigfile.lua
        if vim.bo[buf] and vim.bo[buf].filetype ~= "large_file" and path and vim.fn.getfsize(path) > 1024 * 1024 then
          return "large_file"
        end
      end,
    },
  },
})
