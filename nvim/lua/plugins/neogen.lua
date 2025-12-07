return {
  "danymat/neogen",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "L3MON4D3/LuaSnip",
  },
  cmd = "Neogen",
  keys = {
    {
      "<leader>cn",
      function()
        require("neogen").generate()
      end,
      desc = "Generate Docstring",
    },
  },
  opts = {
    enabled = true,
    snippet_engine = "luasnip",
    input_after_comment = true, -- Auto-jump to first placeholder

    languages = {
      python = {
        template = {
          annotation_convention = "numpydoc", -- Or "google_docstrings", "reST"
        },
      },
      lua = {
        template = {
          annotation_convention = "ldoc",
        },
      },
      typescript = {
        template = {
          annotation_convention = "tsdoc",
        },
      },
      javascript = {
        template = {
          annotation_convention = "jsdoc",
        },
      },
    },
  },
}
