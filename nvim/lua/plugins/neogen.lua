return {
  "danymat/neogen",
  config = function()
    local neogen = require("neogen")
    neogen.setup({
      enable = true,
      languages = {
        python = {
          template = {
            annotation_convention = "numpydoc",
          },
        },
      },
    })
  end,
}
