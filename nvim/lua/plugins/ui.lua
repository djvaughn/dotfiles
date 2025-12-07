return {
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = function(_, opts)
      opts.options = opts.options or {}
      opts.options.theme = "catppuccin"
      opts.options.component_separators = { left = "|", right = "|" }
      opts.options.section_separators = { left = "", right = "" }
      opts.options.globalstatus = true
      opts.options.disabled_filetypes = { statusline = { "dashboard", "alpha", "starter" } }

      opts.sections.lualine_a = {
        { "mode", icon = "\xef\x84\x89" }, -- U+F109
      }

      opts.sections.lualine_b = {
        { "branch", icon = "\xee\x82\xa0" }, -- U+E0A0
        {
          "diff",
          symbols = {
            added = "\xef\x91\x97 ", -- U+F457
            modified = "\xef\x91\x99 ", -- U+F459
            removed = "\xef\x91\x98 ", -- U+F458
          },
        },
        {
          "diagnostics",
          symbols = {
            error = "\xef\x99\x99 ", -- U+F659
            warn = "\xef\x81\xb1 ", -- U+F071
            info = "\xef\x9f\xbc ", -- U+F7FC
            hint = "\xef\xa0\xb5 ", -- U+F835
          },
        },
      }

      opts.sections.lualine_c = {
        {
          "filename",
          path = 1,
          symbols = {
            modified = "●",
            readonly = "\xef\x80\xa3", -- U+F023
          },
        },
        -- LSP Server indicator
        {
          function()
            local buf_clients = vim.lsp.get_clients({ bufnr = 0 })
            if #buf_clients == 0 then
              return ""
            end

            local buf_client_names = {}
            for _, client in pairs(buf_clients) do
              if client.name ~= "null-ls" and client.name ~= "copilot" then
                table.insert(buf_client_names, client.name)
              end
            end

            if #buf_client_names > 0 then
              return "\xef\x85\x88  " .. table.concat(buf_client_names, ", ") -- U+F148 (cog)
            end
            return ""
          end,
          color = { gui = "italic" },
        },
      }

      opts.sections.lualine_x = {
        -- Python virtual environment
        {
          function()
            local venv = vim.env.VIRTUAL_ENV
            if venv then
              return "\xee\x9c\xbc  " .. vim.fn.fnamemodify(venv, ":t") -- U+E73C (python)
            end
            return ""
          end,
          color = { fg = "#98be65" },
        },
        -- Lazy.nvim updates
        {
          function()
            local ok, lazy = pcall(require, "lazy.status")
            if ok and lazy.has_updates() then
              return lazy.updates()
            end
            return ""
          end,
          color = { fg = "#ff9e64" },
        },
        "encoding",
        {
          "fileformat",
          symbols = {
            unix = "\xef\x85\xbc", -- U+F17C
            dos = "\xef\x85\xba", -- U+F17A
            mac = "\xef\x85\xb9", -- U+F179
          },
        },
        "filetype",
      }

      opts.sections.lualine_y = {
        { "progress" },
      }

      opts.sections.lualine_z = {
        { "location" },
      }
    end,
  },
}
