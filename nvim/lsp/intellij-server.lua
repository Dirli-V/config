local function server_root()
  local bin = vim.fn.exepath("intellij-server")
  if bin == "" then
    return nil
  end
  -- The binary is a wrapProgram shell script; strip /bin/intellij-server to get package root
  return bin:gsub("/bin/intellij%-server$", "")
end

local function find_eula_hash()
  local root = server_root()
  if not root then
    return ""
  end
  local f = io.open(root .. "/EULA.txt", "r")
  if not f then
    return ""
  end
  local content = f:read("*a")
  f:close()
  return vim.fn.sha256(content):sub(1, 16)
end

local function find_jdk_home()
  local root = server_root()
  if not root then
    return ""
  end
  -- Use the bundled JBR
  return root .. "/jbr"
end

return {
  cmd = { "intellij-server", "--stdio", "--data-sharing=none", "--eula=" .. find_eula_hash() },
  filetypes = { "java", "kotlin" },
  root_markers = {
    ".idea",
    "pom.xml",
    "build.gradle",
    "build.gradle.kts",
    "settings.gradle",
    "settings.gradle.kts",
    ".git",
  },
  init_options = {
    defaultSdk = find_jdk_home(),
  },
}
