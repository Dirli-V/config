return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    { "folke/neodev.nvim", opts = { experimental = { pathStrict = true } } },
    {
      "hrsh7th/cmp-nvim-lsp",
      cond = function()
        return require("lazyutil").has("nvim-cmp")
      end,
    },
    "simrat39/rust-tools.nvim",
    "aznhe21/actions-preview.nvim",
  },
  init = function()
    local keys = require("lazylspkeymaps").get()
    keys[#keys + 1] = { "<leader>j", vim.diagnostic.goto_next }
    keys[#keys + 1] = { "<leader>k", vim.diagnostic.goto_prev }
    keys[#keys + 1] = {
      "<c-.>",
      function()
        require("actions-preview").code_actions()
      end,
      desc = "Open code actions",
    }
    keys[#keys + 1] = { "<leader>.", vim.lsp.buf.code_action, desc = "Open code actions" }
    keys[#keys + 1] = { "<leader>c.", require("helpers").list_code_action_kinds, desc = "List code action kinds" }
    keys[#keys + 1] = { "<F2>", vim.lsp.buf.rename, desc = "Rename" }
    keys[#keys + 1] = {
      "<a-l>",
      function()
        vim.lsp.buf.format({ async = true })
      end,
      desc = "Format",
    }
  end,
  opts = {
    diagnostics = {
      underline = true,
      virtual_text = {
        spacing = 4,
        source = "if_many",
        prefix = "icons",
      },
      severity_sort = true,
      update_in_insert = true,
    },
    autoformat = true,
    format = {
      formatting_options = nil,
      timeout_ms = nil,
    },
    servers = {
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
      rust_analyzer = {},
      tsserver = {},
      rnix = {},
      taplo = {},
      pyright = {},
      ruff_lsp = {},
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
      rust_analyzer = function(_, opts)
        require("rust-tools").setup({ server = opts })
        return true
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
    -- setup autoformat
    require("lazylspformat").autoformat = opts.autoformat
    -- setup formatting and keymaps
    require("lazyutil").on_attach(function(client, buffer)
      require("lazylspformat").on_attach(client, buffer)
      require("lazylspkeymaps").on_attach(client, buffer)

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
    end)

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

      if opts.setup[server] then
        if opts.setup[server](server, server_opts) then
          goto continue
        end
      elseif opts.setup["*"] then
        if opts.setup["*"](server, server_opts) then
          goto continue
        end
      end
      require("lspconfig")[server].setup(server_opts)
      ::continue::
    end
  end,
}
