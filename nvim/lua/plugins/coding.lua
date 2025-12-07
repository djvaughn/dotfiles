return {
  -- LuaSnip for snippets
  {
    "L3MON4D3/LuaSnip",
    build = "make install_jsregexp",
    dependencies = {
      "rafamadriz/friendly-snippets", -- Python and other snippets
      "cstrap/python-snippets", -- Django, Flask snippets
      "honza/vim-snippets", -- More Python snippets
    },
    config = function()
      -- Load friendly-snippets
      require("luasnip.loaders.from_vscode").lazy_load()
      require("luasnip.loaders.from_snipmate").lazy_load()
    end,
  },

  -- Go support (separate plugin)
  {
    "fatih/vim-go",
    ft = "go",
  },

  -- Rust support (separate plugin)
  {
    "rust-lang/rust.vim",
    ft = "rust",
  },

  -- nvim-cmp with additional sources
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-cmdline", -- Command-line completions
      "hrsh7th/cmp-nvim-lua", -- Neovim Lua API completions
      "saadparwaiz1/cmp_luasnip", -- Snippet completions
      "hrsh7th/cmp-emoji", -- Emoji completions :smile:
      "hrsh7th/cmp-calc", -- Math calculations
      "lukas-reineke/cmp-under-comparator", -- Better sorting for _private items
    },
    opts = function(_, opts)
      local cmp = require("cmp")

      -- Add all new sources
      local sources = {
        { name = "nvim_lua" }, -- Neovim Lua API
        { name = "luasnip" }, -- Snippets
        { name = "emoji" }, -- Emojis
        { name = "calc" }, -- Math calculations
      }

      -- Insert sources into the first priority group
      for _, source in ipairs(sources) do
        table.insert(opts.sources, source)
      end

      -- Add window configuration with rounded borders
      opts.window = {
        completion = cmp.config.window.bordered({
          border = "rounded",
          winhighlight = "Normal:Normal,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None",
        }),
        documentation = cmp.config.window.bordered({
          border = "rounded",
        }),
      }

      -- Better sorting (puts __private items last)
      opts.sorting = {
        comparators = {
          cmp.config.compare.offset,
          cmp.config.compare.exact,
          cmp.config.compare.score,
          require("cmp-under-comparator").under, -- Sort __private last
          cmp.config.compare.kind,
          cmp.config.compare.sort_text,
          cmp.config.compare.length,
          cmp.config.compare.order,
        },
      }
      -- Performance tuning
      opts.performance = {
        debounce = 150, -- Wait 150ms before triggering
        throttle = 60, -- Update every 60ms max
        fetching_timeout = 200, -- Timeout for sources
        max_view_entries = 30, -- Show max 30 items
      }

      -- Formatting with icons and source names
      opts.formatting = {
        fields = { "kind", "abbr", "menu" },
        format = function(entry, item)
          local icons = LazyVim.config.icons.kinds
          if icons[item.kind] then
            item.kind = " " .. icons[item.kind] .. " "
          end

          -- Show source name
          item.menu = ({
            nvim_lsp = "[LSP]",
            luasnip = "[Snip]",
            buffer = "[Buf]",
            path = "[Path]",
            emoji = "[Emoji]",
            calc = "[Calc]",
            nvim_lua = "[Lua]",
          })[entry.source.name]

          return item
        end,
      }

      -- Add Tab and Shift-Tab mappings
      opts.mapping = opts.mapping or {}
      opts.mapping["<Tab>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_next_item()
        elseif vim.snippet.active({ direction = 1 }) then
          vim.snippet.jump(1)
        else
          fallback()
        end
      end, { "i", "s" })

      opts.mapping["<S-Tab>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_prev_item()
        elseif vim.snippet.active({ direction = -1 }) then
          vim.snippet.jump(-1)
        else
          fallback()
        end
      end, { "i", "s" })

      return opts
    end,
  },

  -- Cmdline completion (separate setup)
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-cmdline",
      "dmitmel/cmp-cmdline-history",
    },
    config = function()
      local cmp = require("cmp")

      -- Search completion
      cmp.setup.cmdline({ "/", "?" }, {
        mapping = cmp.mapping.preset.cmdline({
          ["<Tab>"] = cmp.mapping(cmp.mapping.select_next_item(), { "c" }),
          ["<S-Tab>"] = cmp.mapping(cmp.mapping.select_prev_item(), { "c" }),
          ["<C-n>"] = cmp.mapping(cmp.mapping.select_next_item(), { "c" }),
          ["<C-p>"] = cmp.mapping(cmp.mapping.select_prev_item(), { "c" }),
        }),
        sources = {
          { name = "buffer", keyword_length = 3 },
        },
        view = {
          entries = { name = "wildmenu", separator = " | " }, -- Horizontal menu
        },
      })

      -- Command completion
      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline({
          ["<Tab>"] = cmp.mapping(cmp.mapping.select_next_item(), { "c" }),
          ["<S-Tab>"] = cmp.mapping(cmp.mapping.select_prev_item(), { "c" }),
          ["<C-n>"] = cmp.mapping(cmp.mapping.select_next_item(), { "c" }),
          ["<C-p>"] = cmp.mapping(cmp.mapping.select_prev_item(), { "c" }),
        }),
        sources = cmp.config.sources({
          { name = "path", keyword_length = 3 },
        }, {
          {
            name = "cmdline",
            keyword_length = 2,
            option = {
              ignore_cmds = { "Man", "!" }, -- Ignore certain commands
            },
          },
        }),
        formatting = {
          fields = { "abbr", "menu" },
          format = function(entry, item)
            item.menu = ({
              path = "[Path]",
              cmdline = "[Cmd]",
            })[entry.source.name]
            return item
          end,
        },
        window = {
          completion = cmp.config.window.bordered({
            border = "rounded",
          }),
        },
      })
    end,
  },
}
