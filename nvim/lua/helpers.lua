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

function M.get_treesitter_node_under_cursor()
  local ts = require("vim.treesitter")
  local pos = vim.api.nvim_win_get_cursor(0)
  return ts.get_node_at_pos(0, pos[1] - 1, pos[2], {})
end

function M.select_tresssitter_node(node)
  local start_row, start_col, end_row, end_col = node:range()
  vim.api.nvim_win_set_cursor(0, { start_row + 1, start_col })
  vim.cmd("normal! v")
  vim.api.nvim_win_set_cursor(0, { end_row + 1, end_col - 1 })
end

return M
