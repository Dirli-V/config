---@param on_attach fun(client, buffer)
local function on_lsp_attach(on_attach)
  vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
      local buffer = args.buf
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      on_attach(client, buffer)
    end,
  })
end

return {
  "neovim/nvim-lspconfig",
  event = "BufNew",
  dependencies = {
    {
      "folke/neodev.nvim",
      opts = {}, -- opts needs to specified for working plugin
    },
    "hrsh7th/cmp-nvim-lsp",
    "simrat39/rust-tools.nvim",
    "aznhe21/actions-preview.nvim",
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
      nil_ls = {},
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
    on_lsp_attach(function(client, buffer)
      require("lsp.format").on_attach(client, buffer)
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
