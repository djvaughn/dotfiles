return {
  -- Mason: LSP/tool installer
  {
    "mason-org/mason.nvim",
    cmd = "Mason",
    keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" } },
    build = ":MasonUpdate",
    opts = {
      ui = {
        border = "rounded",
      },
    },
  },

  -- Mason-LSPConfig bridge
  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = { "mason-org/mason.nvim" },
    opts = {
      ensure_installed = {
        "pyright",
        "ruff_lsp",
        "tsserver",
        "lua_ls",
        "bashls",
        "jsonls",
      },
    },
  },

  -- LSP Configuration
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "mason-org/mason.nvim",
      "mason-org/mason-lspconfig.nvim",
      "jose-elias-alvarez/typescript.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      -- Get default capabilities from cmp
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- Configure diagnostic display
      vim.diagnostic.config({
        virtual_text = {
          spacing = 4,
          source = "if_many",
          prefix = "●",
        },
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = true,
        float = {
          border = "rounded",
          source = "always",
        },
      })

      -- Customize diagnostic signs
      local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
      for type, icon in pairs(signs) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
      end

      -- LSP handlers with borders
      vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" })
      vim.lsp.handlers["textDocument/signatureHelp"] =
        vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" })

      -- Setup LSP servers
      local lspconfig = require("lspconfig")

      -- Python: Pyright
      lspconfig.pyright.setup({
        capabilities = capabilities,
        settings = {
          python = {
            analysis = {
              typeCheckingMode = "basic",
              autoSearchPaths = true,
              useLibraryCodeForTypes = true,
              diagnosticMode = "workspace",
            },
          },
        },
      })

      -- Python: Ruff
      lspconfig.ruff_lsp.setup({
        capabilities = capabilities,
        on_attach = function(client, bufnr)
          client.server_capabilities.hoverProvider = false
        end,
      })

      -- TypeScript/JavaScript
      require("typescript").setup({
        server = {
          capabilities = capabilities,
        },
      })

      -- Lua
      lspconfig.lua_ls.setup({
        capabilities = capabilities,
        settings = {
          Lua = {
            workspace = { checkThirdParty = false },
            completion = { callSnippet = "Replace" },
            telemetry = { enable = false },
          },
        },
      })

      -- Bash
      lspconfig.bashls.setup({
        capabilities = capabilities,
      })

      -- JSON (without schemastore to avoid the issue)
      lspconfig.jsonls.setup({
        capabilities = capabilities,
      })

      -- LspAttach autocmd for keymaps
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          local buffer = args.buf

          -- Enable inlay hints if supported
          if client and client.server_capabilities.inlayHintProvider then
            vim.lsp.inlay_hint.enable(true, { bufnr = buffer })
          end

          -- Python-specific keymaps
          if client and client.name == "pyright" then
            vim.keymap.set("n", "<leader>co", function()
              vim.lsp.buf.code_action({
                context = { only = { "source.organizeImports" } },
                apply = true,
              })
            end, { buffer = buffer, desc = "Organize Imports (Python)" })
          end

          -- TypeScript-specific keymaps
          if client and client.name == "tsserver" then
            vim.keymap.set(
              "n",
              "<leader>co",
              "<cmd>TypescriptOrganizeImports<cr>",
              { buffer = buffer, desc = "Organize Imports" }
            )
            vim.keymap.set(
              "n",
              "<leader>cR",
              "<cmd>TypescriptRenameFile<cr>",
              { buffer = buffer, desc = "Rename File" }
            )
          end

          -- General LSP keymaps
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = buffer, desc = "Goto Definition" })
          vim.keymap.set("n", "gr", vim.lsp.buf.references, { buffer = buffer, desc = "References" })
          vim.keymap.set("n", "gI", vim.lsp.buf.implementation, { buffer = buffer, desc = "Goto Implementation" })
          vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = buffer, desc = "Hover" })
          vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { buffer = buffer, desc = "Code Action" })
          vim.keymap.set("n", "<leader>cr", vim.lsp.buf.rename, { buffer = buffer, desc = "Rename" })
          vim.keymap.set("n", "<leader>cf", function()
            vim.lsp.buf.format({ async = true })
          end, { buffer = buffer, desc = "Format" })
        end,
      })
    end,
  },
}
