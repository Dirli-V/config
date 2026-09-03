local function find_eula_hash()
  local bin = vim.fn.exepath("intellij-server")
  if bin == "" then
    return ""
  end
  -- Follow symlink to real binary location to find the eula directory
  local real = vim.fn.resolve(bin)
  local root = real:gsub("/bin/intellij%-server$", "")
  local eula_path = root .. "/eula/EULA.txt"
  local f = io.open(eula_path, "r")
  if not f then
    return ""
  end
  local content = f:read("*a")
  f:close()
  return vim.fn.sha256(content):sub(1, 16)
end

local function find_jdk_home()
  local java = vim.fn.exepath("java")
  if java == "" then
    return ""
  end
  local real = vim.fn.resolve(java)
  -- Strip /bin/java to get JDK home
  return real:gsub("/bin/java$", "")
end

return {
  cmd = { "intellij-server", "--stdio", "--data-sharing=none", "--region=not_set" },
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
    eulaHash = find_eula_hash(),
  },
}
