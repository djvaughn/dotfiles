return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed or {}, {
        "bash",
        "css",
        "dockerfile",
        "go",
        "html",
        "javascript",
        "json",
        "lua",
        "markdown",
        "python",
        "rust",
        "typescript",
        "yaml",
      })
    end,
  },

  -- Context
  {
    "nvim-treesitter/nvim-treesitter-context",
    opts = { max_lines = 3 },
  },

  -- Auto-close HTML/JSX tags
  {
    "windwp/nvim-ts-autotag",
    opts = {},
  },
}
