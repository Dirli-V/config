return {
  "mfussenegger/nvim-jdtls",
  dependencies = {
    "neovim/nvim-lspconfig",
  },
  ft = "java",
  config = function(_, _)
    local jdtls = require("jdtls")
    local root_markers = { "gradlew", ".git" }
    local root_dir = require("jdtls.setup").find_root(root_markers)
    local home = os.getenv("HOME")
    local workspace_folder = home .. "/.local/share/jdt-language-server/" .. vim.fn.fnamemodify(root_dir, ":p:h:t")

    local runtimes = {}
    local java_11 = os.getenv("JAVA_11_HOME")
    if java_11 then
      table.insert(runtimes, {
        {
          name = "JavaSE-11",
          path = java_11,
        },
      })
    end

    local config = {
      cmd = {
        vim.fn.exepath("jdt-language-server"),
        "-data",
        workspace_folder,
      },
      root_dir = root_dir,
      settings = {
        java = {
          autobuild = { enabled = false },
          signatureHelp = { enabled = true },
          contentProvider = { preferred = "fernflower" },
          saveActions = {
            organizeImports = true,
          },
          configuration = {
            runtimes = runtimes,
          },
        },
      },
      handlers = {
        ["language/status"] = function() end,
      },
      on_attach = function(client, buffer)
        require("lsp.format").on_attach(client, buffer)
        require("lsp.keymaps").on_attach(client, buffer)
        jdtls.setup_dap({ hotcodereplace = "auto" })

        local opts = { silent = true, buffer = buffer }
        local set = vim.keymap.set
        set("n", "<A-o>", jdtls.organize_imports, opts)
        set("n", "<leader>df", function()
          if vim.bo.modified then
            vim.cmd("w")
          end
          jdtls.test_class()
        end, opts)
        set("n", "<leader>dn", function()
          if vim.bo.modified then
            vim.cmd("w")
          end
          jdtls.test_nearest_method({
            config_overrides = {
              stepFilters = {
                skipClasses = { "$JDK", "junit.*" },
                skipSynthetics = true,
              },
            },
          })
        end, opts)

        set("n", "crv", jdtls.extract_variable_all, opts)
        set("v", "crv", function()
          jdtls.extract_variable_all({ visual = true })
        end, opts)
        set("v", "crm", function()
          jdtls.extract_method({ visual = true })
        end, opts)
        set("n", "crc", jdtls.extract_constant, opts)
        set("n", "gt", jdtls.goto_subjects, opts)
      end,
    }

    vim.api.nvim_create_autocmd("FileType", {
      pattern = "java",
      group = vim.api.nvim_create_augroup("userspace_start_jdtls", { clear = true }),
      callback = function()
        jdtls.start_or_attach(config)
      end,
    })

    jdtls.start_or_attach(config)
  end,
}
