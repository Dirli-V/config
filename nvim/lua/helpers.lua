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
  end

  local output = vim.api.nvim_exec("!git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@'", true)
  local lines = {}
  for line in output:gmatch("([^\n]*)\n?") do
    table.insert(lines, line)
  end
  local default_branch = lines[3]

  local file_path = string.sub(file_abs, string.len(git_dir) + 1)

  local origin = vim.api.nvim_exec("!git config --get remote.origin.url", true)
  local at_index = string.find(origin, "@", 1, true)
  local origin_clean = string.sub(origin, at_index + 1, string.len(origin) - 5)
  local protocol = "https://"
  local result = protocol .. origin_clean
  local is_bitbucket = string.find(origin_clean, "bitbucket", 1, true)
  if is_bitbucket then
    local project_index = string.find(origin_clean, "/", 1, true)
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

function M.trim(str)
  return (str:gsub("^%s*(.-)%s*$", "%1"))
end

function M.find_executable(name)
  local result = vim.api.nvim_exec("!whereis " .. name, true)
  local binary_start_index = string.find(result, ": ", 1, true)
  if not binary_start_index then
    return nil
  end
  local binary_end_index = string.find(result, " ", binary_start_index + 2, true)
  if binary_end_index then
    return M.trim(string.sub(result, binary_start_index + 1, binary_end_index))
  end
  return M.trim(string.sub(result, binary_start_index + 1))
end

local make_code_action_params = function()
  local params = vim.lsp.util.make_range_params()
  params.context = {
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
  local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params)
  local text = "Available Code Action Kinds:"
  for _, res in pairs(result or {}) do
    for _, r in pairs(res.result or {}) do
      text = text .. "\n" .. r.kind .. " (" .. r.title .. ")"
    end
  end
  vim.notify(text)
end

return M
