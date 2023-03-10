return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    { "folke/neodev.nvim", opts = { experimental = { pathStrict = true } } },
    {
      "hrsh7th/cmp-nvim-lsp",
      cond = function()
        return require("lazyvim.util").has("nvim-cmp")
      end,
    },
    "simrat39/rust-tools.nvim",
  },
  init = function()
    local keys = require("lazyvim.plugins.lsp.keymaps").get()
    keys[#keys + 1] = { "<leader>j", vim.diagnostic.goto_next }
    keys[#keys + 1] = { "<leader>k", vim.diagnostic.goto_prev }
    keys[#keys + 1] = { "<c-.>", vim.lsp.buf.code_action, desc = "Open code actions" }
    keys[#keys + 1] = { "<leader>.", vim.lsp.buf.code_action, desc = "Open code actions" }
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
      virtual_text = { spacing = 4, prefix = "●" },
      severity_sort = true,
      update_in_insert = true,
    },
    -- Automatically format on save
    autoformat = true,
    -- options for vim.lsp.buf.format
    -- `bufnr` and `filter` is handled by the LazyVim formatter,
    -- but can be also overridden when specified
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
  },
  config = function(_, opts)
    -- setup autoformat
    require("lazyvim.plugins.lsp.format").autoformat = opts.autoformat
    -- setup formatting and keymaps
    require("lazyvim.util").on_attach(function(client, buffer)
      require("lazyvim.plugins.lsp.format").on_attach(client, buffer)
      require("lazyvim.plugins.lsp.keymaps").on_attach(client, buffer)
    end)

    -- diagnostics
    for name, icon in pairs(require("lazyvim.config").icons.diagnostics) do
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