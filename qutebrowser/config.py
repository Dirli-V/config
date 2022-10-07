config.load_autoconfig()

# Always restore open sites when qutebrowser is reopened.
c.auto_save.session = True

# Prefer dark color schemes
c.colors.webpage.preferred_color_scheme = 'dark'

# Require a confirmation before quitting the application if downloads are active.
c.confirm_quit = ["downloads"]

# Use neovim in alacritty as an editor
c.editor.command = ["wezterm", "start", "--always-new-process", "--class", "beditor", "--",
                    "nvim", "{}", "+call cursor({line},{column0})"]

# Enable hidpi mode
c.qt.highdpi = True

# Enable smooth scrolling
c.scrolling.smooth = True

# Use xplr as file selector
c.fileselect.handler = 'external'
c.fileselect.folder.command         = ["wezterm", "start", "--always-new-process", "--class", "bfileselect", "--", "xplr"]
c.fileselect.multiple_files.command = ["wezterm", "start", "--always-new-process", "--class", "bfileselect", "--", "xplr"] 
c.fileselect.single_file.command    = ["wezterm", "start", "--always-new-process", "--class", "bfileselect", "--", "xplr"] 

# Bind for opening download immediately
config.bind('<Ctrl-o>', 'prompt-open-download', mode='prompt')

# Bind Ctrl-e in command mode to edit the current command
config.bind('<Ctrl+e>', 'edit-command', mode='command')

# Binds for moving through completion items
config.bind('<Ctrl-j>', 'completion-item-focus next', mode='command')
config.bind('<Ctrl-k>', 'completion-item-focus prev', mode='command')

# Rebind close tab to 'dd'
config.unbind('d')
config.bind('dd', 'tab-close')

# Bindings to close all tabs to the left or right of the current tab
config.bind('co', 'tab-only --pinned keep') # Close other tabs
config.bind('ch', 'tab-only --next --pinned keep') # Close tabs to the left
config.bind('cl', 'tab-only --prev --pinned keep') # Close tabs to the right

# Binds for qute-pass
config.bind('zl',  'spawn --userscript qute-pass')
config.bind('zol', 'spawn --userscript qute-pass --otp-only')
config.bind('zpl', 'spawn --userscript qute-pass --password-only')
config.bind('zul', 'spawn --userscript qute-pass --username-only')

# Put the download bar at the bottom of the screen
c.downloads.position = "bottom"

# Remove finished downloads from the download bar after 5 minutes
c.downloads.remove_finished = 300000

# Set up search engines
c.url.searchengines = {
  "DEFAULT": "https://www.google.com/search?q={}",
  "au":      "https://aur.archlinux.org/packages/?K={}",
  "aw":      "https://wiki.archlinux.org/?search={}",
  "d":       "https://www.dict.cc/?s={}",
  "g":       "https://www.google.com/search?q={}",
  "gh":      "https://github.com/search?q={}",
  "yt":      "https://www.youtube.com/results?search_query={}"
}
