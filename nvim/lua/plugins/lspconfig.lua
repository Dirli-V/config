return {
  "neovim/nvim-lspconfig",
  event = "VeryLazy",
  dependencies = {
    {
      "folke/neodev.nvim",
      opts = {}, -- opts needs to be specified for working plugin
    },
    "hrsh7th/cmp-nvim-lsp",
    "simrat39/rust-tools.nvim",
    "aznhe21/actions-preview.nvim",
    "pmizio/typescript-tools.nvim",
    "nvim-lua/plenary.nvim",
    {
      "SmiteshP/nvim-navbuddy",
      dependencies = {
        "SmiteshP/nvim-navic",
        "MunifTanjim/nui.nvim",
      },
      opts = function()
        return {
          window = {
            size = "90%",
          },
          mappings = {
            ["t"] = require("nvim-navbuddy.actions").telescope({
              layout_config = {
                height = 0.90,
                width = 0.90,
              },
            }),
          },
          lsp = {
            auto_attach = true,
          },
        }
      end,
    },
  },
  keys = {
    { "<leader>cl", "<cmd>LspInfo<cr>", desc = "Lsp Info" },
    { "<leader>cs", "<cmd>Navbuddy<cr>", desc = "Symbol tree" },
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
      ltex = {},
      tsserver = {},
      nil_ls = {},
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
      ruff_lsp = function(_, opts)
        local project_path = os.getenv("RUFF_LSP_PROJECT_PATH")
        if project_path then
          opts["init_options"] = {
            settings = {
              args = {
                "--config=" .. project_path,
              },
            },
          }
        end
      end,
    },
    additional_keys = {
      ruff_lsp = {
        {
          "<a-o>",
          function()
            require("helpers").execute_code_action("source.organizeImports")
          end,
          desc = "Organize Imports",
        },
      },
    },
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
    local capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())

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
