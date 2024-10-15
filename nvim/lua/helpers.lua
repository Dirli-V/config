local M = {}

function M.copy_git_file_to_clipboard(include_line)
  local file_abs = vim.api.nvim_buf_get_name(0)
  local git_dir
  for dir in vim.fs.parents(file_abs) do
    if vim.fn.isdirectory(dir .. "/.git") == 1 then
      git_dir = dir
      break
    end
  end

  if not git_dir then
    print("Not in a git directory")
    return
  end

  ---@diagnostic disable-next-line: undefined-field
  local output = vim.fn.execute("git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@'")
  local lines = {}
  for line in output:gmatch("([^\n]*)\n?") do
    table.insert(lines, line)
  end
  local default_branch = lines[3]

  local file_path = string.sub(file_abs, string.len(git_dir) + 1)

  ---@diagnostic disable-next-line: undefined-field
  local origin = vim.fn.execute("git config --get remote.origin.url", true)
  local at_index = string.find(origin, "@", 1, true)
  local origin_clean = string.sub(origin, at_index + 1, string.len(origin) - 5)
  local protocol = "https://"
  local result = protocol .. origin_clean
  local is_bitbucket = string.find(origin_clean, "bitbucket", 1, true)
  if is_bitbucket then
    local project_index = string.find(origin_clean, "/", 1, true)
    if not project_index then
      print("Bitbucket project could not be parsed from origin" .. origin_clean)
      return
    end
    local repo_index = string.find(origin_clean, "/", project_index + 1, true)
    local bitbucket_path = "/projects"
      .. string.sub(origin_clean, project_index, repo_index)
      .. "repos/"
      .. string.sub(origin_clean, repo_index + 1)
    result = protocol .. string.sub(origin_clean, 1, project_index - 1) .. bitbucket_path .. "/browse" .. file_path
  end
  local is_github = string.find(origin_clean, "github", 1, true)
  if is_github then
    result = protocol .. string.gsub(origin_clean, ":", "/") .. "/blob/" .. default_branch .. file_path
  end

  if include_line then
    local line_number = vim.api.nvim_win_get_cursor(0)[1]

    if is_bitbucket then
      result = result .. "#" .. line_number
    end
    if is_github then
      result = result .. "#L" .. line_number
    end
  end

  vim.fn.setreg("+", result)
end

local make_code_action_params = function()
  local params = vim.lsp.util.make_range_params()
  params.context = {
    ---@diagnostic disable-next-line: missing-parameter
    diagnostics = vim.lsp.diagnostic.get_line_diagnostics(),
  }
  return params
end

function M.execute_code_action(kind)
  if not kind then
    return
  end
  local params = make_code_action_params()
  params.context.only = { kind }
  ---@diagnostic disable-next-line: missing-parameter
  local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params)
  for _, res in pairs(result or {}) do
    for _, r in pairs(res.result or {}) do
      if r.edit then
        vim.lsp.util.apply_workspace_edit(r.edit, "utf-8")
      else
        vim.lsp.buf.execute_command(r.command)
      end
    end
  end
end

function M.list_code_action_kinds()
  local params = make_code_action_params()
  ---@diagnostic disable-next-line: missing-parameter
  local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params)
  local text = "Available Code Action Kinds:"
  for _, res in pairs(result or {}) do
    for _, r in pairs(res.result or {}) do
      text = text .. "\n" .. r.kind .. " (" .. r.title .. ")"
    end
  end
  vim.notify(text)
end

-- returns the root directory based on:
-- * lsp workspace folders
-- * lsp root_dir
-- * root pattern of filename of the current buffer
-- * root pattern of cwd
---@return string
function M.get_root()
  ---@type string?
  local path = vim.api.nvim_buf_get_name(0)
  path = path ~= "" and vim.loop.fs_realpath(path) or nil
  ---@type string[]
  local roots = {}
  if path then
    for _, client in pairs(vim.lsp.get_clients({ bufnr = 0 })) do
      local workspace = client.config.workspace_folders
      local paths = workspace and vim.tbl_map(function(ws)
        return vim.uri_to_fname(ws.uri)
      end, workspace) or client.config.root_dir and { client.config.root_dir } or {}
      for _, p in ipairs(paths) do
        local r = vim.loop.fs_realpath(p)
        if r and path:find(r, 1, true) then
          roots[#roots + 1] = r
        end
      end
    end
  end
  table.sort(roots, function(a, b)
    return #a > #b
  end)
  ---@type string?
  local root = roots[1]
  if not root then
    path = path and vim.fs.dirname(path) or vim.loop.cwd()
    ---@type string?
    root = vim.fs.find({ ".git" }, { path = path, upward = true })[1]
    root = root and vim.fs.dirname(root) or vim.loop.cwd()
  end
  ---@cast root string
  return root
end

function M.close_all_floating_windows()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local config = vim.api.nvim_win_get_config(win)
    if config.relative ~= "" then
      vim.api.nvim_win_close(win, false)
    end
  end
end

return M
