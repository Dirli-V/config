return {
  "neovim/nvim-lspconfig",
  event = "VeryLazy",
  dependencies = {
    {
      "folke/lazydev.nvim",
      ft = "lua",
      opts = {
        library = {},
      },
    },
    "Saghen/blink.cmp",
    {
      "Chaitanyabsprip/fastaction.nvim",
      opts = {
        dismiss_keys = { "q", "<esc>" },
      },
    },
    "pmizio/typescript-tools.nvim",
    "nvim-lua/plenary.nvim",
    -- Use the java plugin when it no longer requires mason
    -- {
    --   "nvim-java/nvim-java",
    --   dependencies = {
    --     "nvim-java/lua-async-await",
    --     "nvim-java/nvim-java-core",
    --     "nvim-java/nvim-java-test",
    --     "nvim-java/nvim-java-dap",
    --     "MunifTanjim/nui.nvim",
    --     "mfussenegger/nvim-dap",
    --   },
    -- },
  },
  keys = {
    { "<leader>cl", "<cmd>LspInfo<cr>", desc = "Lsp Info" },
  },
  opts = {
    diagnostics = {
      underline = true,
      virtual_text = {
        spacing = 4,
        source = "if_many",
      },
      severity_sort = true,
      update_in_insert = true,
    },
    servers = {
      bashls = {},
      jsonls = {
        cmd = { "vscode-json-languageserver", "--stdio" },
      },
      lua_ls = {
        settings = {
          Lua = {
            workspace = {
              checkThirdParty = false,
            },
            completion = {
              callSnippet = "Replace",
            },
          },
        },
      },
      tsserver = {},
      nixd = {},
      taplo = {},
      pyright = {
        root_dir = { "requirements.txt" },
        start_root_search_from_buffer_location = true,
      },
      pylsp = {
        root_dir = { "requirements.txt" },
        start_root_search_from_buffer_location = true,
        settings = {
          pylsp = {
            plugins = {
              black = {
                enabled = true,
              },
              flake8 = {
                enabled = true,
                maxLineLength = 160,
              },
              mypy = {
                enabled = true,
                strict = true,
              },
            },
          },
        },
      },
      gopls = {},
      typos_lsp = {
        init_options = {
          diagnosticSeverity = "Info",
        },
      },
      jdtls = {},
      intelephense = {},
      kotlin_language_server = {
        root_dir = { "settings.gradle.kts", "settings.gradle" },
      },
      yamlls = {
        settings = {
          yaml = {
            schemas = {
              ["kubernetes"] = "*/deployment/**/*",
            },
          },
        },
      },
    },
    setup = {
      tsserver = function(_, opts)
        require("typescript-tools").setup({
          server = opts,
          settings = {
            publish_diagnostic_on = "change",
          },
        })
        return true
      end,
      -- Use the java plugin when it no longer requires mason
      -- jdtls = function(_, _)
      --   local java_ok, java = pcall(require, "java")
      --   if java_ok then
      --     pcall(java.setup, {
      --       jdk = {
      --         auto_install = false,
      --       },
      --     })
      --   end
      --   return false
      -- end,
    },
    additional_keys = {},
  },
  config = function(_, opts)
    local on_attach = function(client, buffer)
      require("lsp.keymaps").on_attach(client, buffer)

      if opts.additional_keys[client.name] then
        local Keys = require("lazy.core.handler.keys")
        for _, keys in pairs(opts.additional_keys[client.name]) do
          local key_opts = Keys.opts(keys)
          key_opts.has = nil
          key_opts.silent = key_opts.silent ~= false
          key_opts.buffer = buffer
          vim.keymap.set(keys.mode or "n", keys[1], keys[2], key_opts)
        end
      end
    end
    vim.api.nvim_create_autocmd("LspAttach", {
      callback = function(args)
        local buffer = args.buf
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        on_attach(client, buffer)
      end,
    })

    -- diagnostics
    for name, icon in pairs(require("config.icons").diagnostics) do
      name = "DiagnosticSign" .. name
      vim.fn.sign_define(name, { text = icon, texthl = name, numhl = "" })
    end
    vim.diagnostic.config(opts.diagnostics)

    local servers = opts.servers
    local capabilities = require("blink.cmp").get_lsp_capabilities(vim.lsp.protocol.make_client_capabilities())

    for server, config_opts in pairs(servers) do
      local server_opts = vim.tbl_deep_extend("force", {
        capabilities = vim.deepcopy(capabilities),
      }, config_opts or {})
      if server_opts["root_dir"] then
        ---@diagnostic disable-next-line: param-type-mismatch
        server_opts["root_dir"] = require("lspconfig").util.root_pattern(unpack(server_opts["root_dir"]))
        if server_opts["start_root_search_from_buffer_location"] then
          local buffer_location = vim.api.nvim_buf_get_name(0)
          if buffer_location ~= "" then
            local file_path = vim.loop.fs_realpath(buffer_location)
            if file_path then
              local root_dir = server_opts["root_dir"]
              server_opts["root_dir"] = function()
                ---@diagnostic disable-next-line: redundant-parameter
                return root_dir(vim.fs.dirname(file_path))
              end
            end
          end
        end
      end

      if opts.setup[server] then
        if opts.setup[server](server, server_opts) then
          goto continue
        end
      end
      require("lspconfig")[server].setup(server_opts)
      ::continue::
    end
  end,
}
